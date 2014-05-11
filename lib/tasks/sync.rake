# Synchronisation tasks to be performed once (then never again) to build the initial version
# of the new ICU database (www_production) from data in the old ICU database (icuadmi_main)
# and also the ratings database (ratings_production).
# Run it like this:
#   $ bin/rake sync:all > ~/sync.log     # if performing for the first time, or
#   $ bin/rake sync:all[f] > ~/sync.log  # if redoing because of changes
namespace :sync do
  desc "Convert icuadmi_main/clubs to www_production/clubs"
  task :clubs, [:force] => :environment do |task, args|
    ICU::Legacy::Club.new.synchronize(args[:force])
  end

  desc "Convert icuadmi_main/icu_players www_production/players"
  task :players, [:force] => :environment do |task, args|
    ICU::Legacy::Player.new.synchronize(args[:force])
  end

  desc "Convert icuadmi_main/icu_player_changes to www_production/journal_entries"
  task :changes, [:force] => :environment do |task, args|
    ICU::Legacy::Change.new.synchronize(args[:force])
  end

  desc "Update www_production/player/status"
  task :status, [:force] => :environment do |task, args|
    ICU::Legacy::Status.new.update(args[:force])
  end

  desc "Convert ratings_production/old_players to www_production/players"
  task :archive, [:force] => :environment do |task, args|
    ICU::Legacy::Archive.new.synchronize(args[:force])
  end

  desc "Convert icuadmi_main/members to www_production/users"
  task :members, [:force] => :environment do |task, args|
    ICU::Legacy::Member.new.synchronize(args[:force])
  end

  desc "Convert icuadmi_main/{subscriptions,subs_offline,subs_forlife} to www_production/subscriptions"
  task :subscriptions, [:force] => :environment do |task, args|
    ICU::Legacy::Subscription.new.synchronize(args[:force])
  end

  desc "Convert icuadmi_main/events to www_production/events"
  task :events, [:force] => :environment do |task, args|
    ICU::Legacy::Event.new.synchronize(args[:force])
  end

  desc "Convert icuadmi_main/images to www_production/images"
  task :images => :environment do |task|
    ICU::Legacy::Image.new.synchronize
  end

  desc "Check all synchronized data"
  task :check => :environment do |task|
    ICU::Legacy::Check.new.check
  end

  desc "Perform all synchronization tasks"
  task :all, [:force] => [:clubs, :players, :changes, :status, :archive, :members, :subscriptions, :events, :images, :check]
end
