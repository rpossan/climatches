namespace :env do
  desc 'Load defaults settings'
  task :reset do
    default = 'default.env'
    raise 'Your environment is not initialized. Run command:'.red unless File.exist? default
    FileUtils.cp 'sample.env', 'default.env'
    puts "'default.env' was reset succesfully!"
  end
  
  desc 'Init a default.env file overwriting existing'
  task :init do
    default = 'default.env'
    raise 'Your environment is already initialized. Run update or reset to load default settings'.red if File.exist? default
    FileUtils.cp 'sample.env', 'default.env'
    puts "'default.env' was created succesfully!"
  end

  desc 'Update default.env with sample file. Do not overwrite any file'
  task :update do
    default = File.open 'default.env'
    sample = File.open 'sample.env'
    raise 'Your environment is not initialized. Run command:'.red + 'rake env:init'.green unless File.exist? sample
    sample.each_line do |sample_line|
      has_line = false
      default.each_line do |default_line|
        has_line = (sample_line == default_line)
        break if has_line
      end
      File.open('default.env', 'a+') { |f| f.puts sample_line } unless has_line
    end
    puts "'default.env' was updated succesfully!".green
  end

end