set :output, "log/cron.log"
set :job_template, nil

every :day, at: "3:15am" do
  rake "cleanup:empty[f]"
end

every :day, at: "3:45am" do
  rake "cleanup:unpaid[f]"
end

every :day, at: "4:14am" do
  rake "mail:stats"
end

every :day, at: "4:16am" do
  rake "mail:events"
end
