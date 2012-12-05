require 'yaml'

tasks = ['01', '02', '03', '04']

desc 'Checks everything'
task :check do
  tasks.each do |task_number|
    Rake::Task["tasks:#{task_number}"].invoke
  end
end

desc 'Starts watchr'
task :watch do
  system 'watchr watchr.rb'
end

namespace :tasks do
  tasks.each do |task_number|
    task(task_number) { Rake::Task['tasks:run'].execute(task_number) }
  end

  task :run, :task_id do |t, arg|
    index = arg
    Rake::Task['tasks:skeptic'].execute index
    Rake::Task['tasks:spec'].execute index
  end

  task :spec, :task_id do |t, arg|
    index = arg
    system("rspec --require ./solutions/#{index}.rb --fail-fast --color specs/#{index}_spec.rb") or exit(1)
  end

  task :skeptic, :task_id do |t, arg|
    index = arg.to_i
    opts = YAML.load_file('skeptic.yml')[index]
      .map { |key, value| [key, (value == true ? nil : value)].compact }
      .map { |key, value| "--#{key.tr('_', '-')} #{value}".strip }
      .join(' ')

    system("skeptic #{opts} solutions/#{'%02d' % index}.rb") or exit(1)
  end
end
