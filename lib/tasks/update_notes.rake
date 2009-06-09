desc "Update the old, unencrypted notes to new, encrypted notes."
task :update_notes => :environment do
  @entries_updated = []

  Entry.find(:all).each do |entry|
    if entry.respond_to?(:notes) && !entry.notes.blank?
      entry.description = entry.notes
      if entry.save
        @entries_updated << entry
        RAILS_DEFAULT_LOGGER.warn("Note Updater: Entry ##{entry.id} updated.")
      end
    end
  end

  puts "#{@entries_updated.length} entries updated. See #{RAILS_ENV}.log for more details."
  RAILS_DEFAULT_LOGGER.flush
end
