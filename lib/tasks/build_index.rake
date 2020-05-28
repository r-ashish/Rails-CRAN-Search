namespace :build_index do
  desc "Fetch and index 50 R packages from CRAN server!"

  task :build, [:num_packages] => :environment do |t, args|
    IndexBuilder.new.execute(args.num_packages.to_i)
  end
end