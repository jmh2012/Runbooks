#!/usr/bin/env ruby
require "runbook"

runbook = Runbook.book "AIDE Database Update" do
   description <<-DESC
This is a runbook that will update the system's AIDE file integrity 
database if there are changes.
   DESC
  layout [[
    [:runbook, :log],
  ]]
   section "Update AIDE database" do
     step "Check if AIDE needs to be updated" do
       tmux_command "head -n 10 /var/log/aide/aide.log", :log
       confirm "Have you checked to see if the changes logged in /var/log/aide/aide.log are expected?"
     end
     step "Build new AIDE database" do
       command "aide --update | true"
     end
     step "Overwrite old AIDE database" do
       command "mv -f /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz"
     end
     step "Check if the new database matches filesystem" do
       command "aide --check | true"
       tmux_command "head -n 10 /var/log/aide/aide.log", :log
       confirm "Does the new DB match the filesystem?"
     end
   end
end

if __FILE__ == $0
   Runbook::Runner.new(runbook).run
else
   runbook
end

