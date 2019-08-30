#!/usr/bin/env ruby
require "runbook"

runbook = Runbook.book "AIDE Database Update" do
   description <<-DESC
This is a runbook that will update the system's AIDE file integrity 
database if there are changes.
   DESC

   section "Update AIDE database" do
     step "Check if AIDE needs to be updated" do
       note "Running AIDE check on filesystem..."
       assert %q{aide --check | grep "found differences between 
database and filesystem"}
       confirm "Have you checked to see if changes logged in 
/var/log/aide/aide.log are expected?"
     end
     step "Build new AIDE database" do
       command "aide --update"
     end
     step "Overwrite old AIDE database" do
       command "mv -f /var/lib/aide/aide.db.new /var/lib/aide.db"
     end
     step "Check if the new database matches filesystem" do
       assert %q{aide --check | grep "All files match AIDE database"}
     end
   end
end

if __FILE__ == $0
   Runbook::Runner.new(runbook).run
else
   runbook
end
