# CLIMATCHES
*Match your climate song*

Este é um projeto-teste com base nos requisitos do exercício no link: https://github.com/ifood/ifood-backend-advanced-test

>Me disponho para explicar detalhadamente cada ponto da solução caso seja necessário

1. [Introdução](#1---introdução)
2. [Desenvolvimento](#2---desenvolvimento)
3. [Arquitetura](#3---arquitetura)
4. [Solução](#4---solução)
5. [Background Jobs](#5---background-jobs)
6. [Qualidade](#6---qualidade)
7. [Deploy](#7---deploy)
8. [Evidências](#8---evidências)
9. [Melhorias Previstas](#9---melhorias-previstas)


## 1 - Introdução

Dados os requisitos tanto funcionais quanto não funcionais, implementei uma solução de API baseada em REST e com arquitetura
de versionamento garantindo retrocompatibilidade, disponibilidade e escalabilidade na evolução da mesma.
Outro ponto que tomei como importante foi com relação aos requisitos não funcionais, onde tomei os cuidados para
garantir a disponibilidade (responsível), resiliência e tolerante a falhas.

Como solução para atender tanto os requisitos funcionais quanto não funcionais, eu optei por utilizar Cache das informações
tanto temperaturas quanto de playlist, baseados em previsões do tempo e atualizações diárias playlists conforme a categoria.

## 2 - Desenvolvimento

Para o desenvolvimento, utilizei os recursos de Issues do próprio Gihub onde me organizei seguindo os padrões de
desenvolvimento sugerido por Martin Fowler "Feature branch" (https://martinfowler.com/bliki/FeatureBranch.html) onde
para cada Issue eu criei uma nova branch, desenvolvi, testei e mesclei com a master através do Pull Request do Githib.

Apliquei técnicas de Code Review sobre os meus próprios Pull Requests, tentando sempre seguir um padrão de desenvolvimento.

Também utilizei da técnica de TDD (Test-driven Development) onde primeiramente escrevi alguns testes imaginando o comportamento
das classes e fui moldando o desenvolvimento conforme os testes me guiavam.

## 3 - Arquitetura

Para o desenvolvimento, utilizei as seguintes ferramentas:

* Linguagem de Programação: Ruby
* Framework: Rails 5 API (Apenas o módulo de API do Rails)
* Banco de Dados: PostgreSql
* Cache: Própria do Rails, mas pode ser usada com Redis, Memcache ou qualquer outra
* Servidor de Aplicação: Puma
* Background Jobs: Próprio Rails, mas pode ser usado com Redis ou Sidekiq

Utilizei o pattern "Service Objects" para assegurar que minha camada de serviço de integração com o Open Weather e do
Spotify possam ser reutilizadas e também testadas isoladamente, assim separando a camada lógica do resto da aplicação, na
qual o foco é prover a API.

Utilizei a gem "versionist" para prover versionamento da minha API, podendo assim evoluí-la para novas versões sem impactar
os clientes das versões anteriores.

A aplicação utiliza de configurações padrões que são carregadas através de variáveis de ambiente, como as chaves de acesso
das APIs, endpoints externos, etc.
Estas configurações se encontram em sample.env, onde possui valores que seriam apenas para teste. Em produção estes dados
são armazenados no ambiente. Para desenvolvimento, é necessário rodar a rake task para gerar o default.env baseado no sample:

```sh
rake env:init
```

## 4 - Solução
### Temperatura
Ao bater na url passando coordenada gps ou nome de cidade, e a mesma seja encontrada pela API do Open Weather,
a cidade será incluída na tabela chamada "weathers" para ficar armazenado o registro da mesma. Neste mesmo momento, o próprio método
irá carregar pela mesma API as previsões de temperaturas de cada 3 horas no período dos próximos 5 dias. Essas previsões são armazenadas
na tabela forecasts associadas à cidade (weather) principal.

> Com esses dados de forecast, caso a cidade seja chamada novamente via API, o sistema irá buscar os dados da previsão, e não
mais da API externa do Open Weather. Com isso aumenta a velocidade de resposta, reduz o uso de recursos da API (relativamente
reduz custos) e por fim garante que se a API externa estiver fora ou quebrada, a minha API irá se manter por pelo menos os próximos
5 dias, baseado com a cache de dados de previsão de tempo.

Quando usada a cache, a temperatura é baseada na média do dia, conforme pode ser notado no código abaixo:

```ruby
def average_degrees(date=Date.today)
  forecasts.where(date: Date.today).average(:degrees).to_i
end
```

### Playlists

Ao testar a API de recomendação de playlists do Spotify, notei que a mesma fornece mais de uma playlist baseada na categoria,
por isso na resposta JSON da minha api, optei por juntar todas as playlists e responder só com a lista de títulos, no mesmo
nó "tracks" do JSON.

Com a Playlist acontece um sistema de cache parecido, onde ao pesquisar pela cidade ou GPS, o sistema irá verificar em qual
categoria a temperatura se encaixa, e com base nisso irá buscar SEMPRE no banco de dados, pois a alimentação das playlists
por gênero é feita a cada 6 horas (configurável) através de um background Job, assim melhorando performance e responsividade, como
também evitando falhas caso sua cota de recurso do Spotify seja excedida ou expirada, ou até mesmo algum erro de conexão externo
com a API.

Neste caso, a cada execução do job, todas as playlists são excluídas e inseridas novamente, tudo isso dentro de um bloco de
transaction, para caso houver falhas no processo, voltar os dados e enfileirar o job para ser reprocessado (Sidekiq por exemplo).

### API
Utilizei o versionamento da API para garantir retrocompatiblidade com os clientes e assim poder evoluí-la de forma escalar.
Todo o negócio se baseia no endpoint rest, onde é possível passar como parâmetro tanto a cidade, ou latitude e longitude
seguidos da barra na separação de cada um, conforme nos exemplos abaixo:

> https://climatches.herokuapp.com/v1/

Por cidade:
>https://climatches.herokuapp.com/v1/playlists/campinas

Por GPS:
>https://climatches.herokuapp.com/v1/playlists/27.023967/18.529390

Todo o códigose encontra no controller "playlists_controller.rb" no qual utiliza das classes de serviço WeatherService e
PlaylistsService, econtrados ambos na pasta app/services.

Neste caso, a única rota implementada foi a de playlists, que só recebe GET como método.

## 5 - Background Jobs

Implementei 2 backgrounds Jobs para serem executados a cada 6 (configurável) horas:

* Weather Forecast Job: Busca/atualiza a previsão de temperatura das cidades já conhecidas (cacheadas) para os próximos 5 dias

* Playlists: A cada 6 horas atualiza as playlists e faixas por categoria

Para facilidade de deploy, utilizei o crontab para agendamento dos Jobs em Background, porém como melhoria é imprescindível
utilizar de uma plataforma específica para isso, como o Sidekiq por exemplo.

Sobre a periocidade, acredito que a previsão do tempo não alterna muito dentro de cada 6 horas, assim como a recomendação
das playlists e tracks, porém estes parâmetros são ajustáveis.

```sh
0 0,6,12,18 * * * /bin/bash -l -c 'cd /shared/climatches && bundle exec bin/rails runner -e production '\''PlaylistsJob.perform'\'''

0 0,6,12,18 * * * /bin/bash -l -c 'cd /shared/climatches && bundle exec bin/rails runner -e production '\''WeatherForecastJob.perform'\'''
```

## 6 - Qualidade

> Todos os relatórios se encontram no repositório nas pastas "coverage/index.html" e "tmp/rubycritics/"

Para qualidade de código e cobertura de testes, utilizei das seguintes gems para auxiliar:

* Simplecov: Análise da cobertura de testes da aplicação
* Ruby Critic: Análise da qualidade de código (falhas, code smells, etc)
* Brakeman: Falhas e brechas de segurança no código
* Rubocop: Boas práticas baseado nas recomendações da comunidade.

### Resultados
> 99,44% de cobertura de testes

![](https://github.com/rpossan/files/blob/master/climatches/coverage.png)

Não consegui alcançar 100% pois não consegui simular ou mockar um teste de falha de comunicação com a API,
numa única classe:

![](https://github.com/rpossan/files/blob/master/climatches/coverage_pending.png)


> Nota A na maioria dos códigos, com poucas ocorrências com B e nenhuma abaixo disso. Classifiação 98.14/100

![](https://github.com/rpossan/files/blob/master/climatches/quality.png)

## 7 - Deploy

Optei por utilizar o serviço PaaS (Platform as a Service) do Heroku, pela facilidade e agidade no deploy
como também pelos recursos para acompanhar e monitorar a aplicação, podendo haver integração de um processo de
Continuous Integration.
Porém deixei criado um Dockerfile na raiz do projeto para criação básica do ambiente.

## 8 - Evidências

Segue abaixo algumas screenshots para evidenciar alguns testes que eu fiz com a aplicação em produção no heroku:

New York - 7 graus - Música Clássica:

![](https://github.com/rpossan/files/blob/master/climatches/newyork.png)

Por GPS:

![](https://github.com/rpossan/files/blob/master/climatches/newyork_gps.png)

Temperatura

![](https://github.com/rpossan/files/blob/master/climatches/newyork_temp.png)

Darwin - 32 graus - Party Music

![](https://github.com/rpossan/files/blob/master/climatches/darwin.png)

Temperatura:

![](https://github.com/rpossan/files/blob/master/climatches/darwin_temp.png)


Cidade não encontrada:

![](https://github.com/rpossan/files/blob/master/climatches/not_found.png)

## 9 - Melhorias Previstas

* Usar uma collection do MongoDB para armazenar as previsões de temperatura com cycling e expire de 1 dia,
pois a previsão que passar a data corrente, não serve mais. Assim teria sempre uma collection limpa de previsões, pois
com o tempo e uso da API, iriam aumentar os dados.

* Utilizar Sidekiq como ferramenta de Background Jobs para poder administrar as filas e execução dos jobs

* Cache com Redis ou Memcache: Fazer uma camada acima do banco de dados para disponibilizar os dados de cache de forma
mais rápida

* Implemetar testes de performance (jmeter)

* Cobertura de testes 100% e fazer code review

* Criar V2 da api para fazer testes de interoperabilidade

* Implementar testes de segurança e ataques