#
# This will resquence tree_nodes, which can cause problems if the object loses it Sequence
# ( this can happen in transfers and whatnot ) 

require 'thread'

class Resequencer
  
  @@running = false
  @@klasses = [ :ArchivalObject, :DigitalObjectComponent, :ClassificationTerm]


  class << self

    def running?
      @@running
    end

    def resequence(klass)
      repos = Repository.dataset.select(:id).map {|rec| rec[:id]} 
      repos.each do |r|
        DB.attempt {
          Kernel.const_get(klass).resequence(r)
           return
        }.and_if_constraint_fails {
          # if there's a failure, just keep going.  
          return 
        } 
      end
    end

    def resequence_all
      @@klasses.each do |klass|
        self.resequence(klass)
      end
    end


    def run(klasses = @@klasses )
      begin
        @@running = true 
        klasses = klasses & @@klasses 
        klasses.each do |klass|
            self.resequence(klass) 
        end 
      ensure
        @@running = false
      end
    end

  end
end
