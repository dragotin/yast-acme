# Copyright (c) 2017 SUSE Linux GmbH.
#  All Rights Reserved.

#  This program is free software; you can redistribute it and/or
#  modify it under the terms of version 2 or 3 of the GNU General
#  Public License as published by the Free Software Foundation.

#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.   See the
#  GNU General Public License for more details.

#  You should have received a copy of the GNU General Public License
#  along with this program; if not, contact SUSE LLC.

#  To contact Novell about this file by physical or electronic mail,
#  you may find current contact information at www.suse.com

require "yast"
require "acme/query_presenter.rb"
require "acme/newcert_dialog.rb"

Yast.import "UI"
Yast.import "Label"
Yast.import "Popup"

module ACME


  # Dialog to display journal entries with several filtering options
  class CaDialog

    include Yast::UIShortcuts
    include Yast::I18n
    include Yast::Logger

    def initialize
      textdomain "acme"

      @query = QueryPresenter.new
      read_entries
    end

    # Displays the dialog
    def run
      return unless create_dialog

      begin
        return event_loop
      ensure
        close_dialog
      end
    end

  private

    # Draws the dialog
    def create_dialog
      Yast::UI.OpenDialog(
        Opt(:decorated, :defaultsize),
        VBox(
          # Header
          Heading(_("Let's Encrypt Certificates")),

          # Log entries
          VSpacing(0.3),
          HBox(
            table,

          # Buttons to manipulate the certificates
            VBox(
              VWeight(1, PushButton(Id(:new), _("New Cert..."))),
              # VWeight(1, PushButton(Id(:revoke), _("Revoke"))),
            VWeight(1, PushButton(Id(:remove), _("Remove"))),
              VStretch()
            )
          ),
          VSpacing(0.3),

          # Footer buttons
          ButtonBox(
            PushButton(Id(:close), Opt(:key_F9), Yast::Label.CloseButton)
          )
        )
      )
    end

    def close_dialog
      Yast::UI.CloseDialog
    end

    # Simple event loop
    def event_loop
      loop do
        case input = Yast::UI.UserInput
        when :close
          close_dialog
          break
        when :new
          # The user clicked the filter button
          newcert = NewCertDialog.new
          newcert.run
          hostnames = newcert.hostnames
          if not has_entry(hostnames)
            new_entry("/etc/dehydrated/domains.txt", hostnames.join(" "))
          end
        when :revoke
          # The content of the search box changed
        when :remove
          # The user clicked the refresh button
          selected = Yast::UI.QueryWidget(Id(:entries_table), :CurrentItem)
          remove_entry("/etc/dehydrated/domains.txt", selected)
        else
          log.warn "Unexpected input #{input}"
        end
      end
    end

    def has_entry(hostnames)
#      @entries.each{ |entry| entry.hostname == hostnames[0] add_hostname == hostnames[1:-1] } }
      nil
    end

    # gets a line from the domains.txt. Splits it, and leaves the first entry
    # at the beginning, but sorts all other entries
    def cmp_hostnames( line, hostnames_to_remove )
        from_file_hn = line.split( /\s+/ )
        hn1 = [from_file_hn[0] ]
        hn1 << from_file_hn[1..-1].sort

        hn1 == hostnames_to_remove
    end

    # remove an entry from domains.txt to remove the cert
    def remove_entry(file, hname)
        hostnames_to_remove = []
        @entries.each do |entry|
          if entry.hostname == hname
            hostnames_to_remove << entry.hostname
            hostnames_to_remove << entry.additional_hostnames.sort
            break
          end
        end

        newcontent = []
        open(file, 'r') do |f|
          f.each_line do |l|
            # only add entries to the new file which are not caught be the
            # search string regexp built above
            newcontent << l unless cmp_hostnames(l, hostnames_to_remove)
          end
        end

       open(file, 'w') do |f|
         newcontent.each { |line| f.puts line}
       end
       refresh_table
    end

    # Create line in domains.txt
    def new_entry(file, entry)
      open(file, 'a') { |f|
          f.puts entry
      }
      refresh_table
    end

    DEHYD_CMD = "LANG=C sudo -u dehydrated /usr/bin/dehydrated -c"
    # Call the dehydrated script to refresh the certificates
    def refresh_certificates
      cmd = "#{DEHYD_CMD}".strip
      path = Yast::Path.new(".target.bash_output")
      cmd_result = Yast::SCR.Execute(path, cmd)

      if cmd_result["exit"].zero?
        content = cmd_result["stdout"]
      else
        if cmd_result["stderr"] =~ /^Failed to .* timestamp:/
          # Most likely, journalctl bug when an empty list is found
          ""
        else
          raise "Calling journalctl failed: #{cmd_result["stderr"]}"
        end
      end

    end

    def refresh_table
      refresh_certificates
      read_entries
      Yast::UI.ChangeWidget(Id(:entries_table), :Items, table_items)
    end

    # Table widget to display log entries
    def table
      headers = @query.columns.map {|c| c[:label] }

      Table(
        Id(:entries_table),
        Opt(:keepSorting),
        Header(*headers),
        table_items
      )
    end

    def table_items
      entries_fields = @entries.map do |entry|
        @query.columns.map {|c| entry.send(c[:method]) }
      end
      # Return the result as an array of Items
      entries_fields.map {|fields| Item(*fields) }
    end

    def read_entries
      log.info "Calling acme'"
      @entries = @query.entries
      log.info "Call to acme returned #{@entries.size} entries."
    rescue => e
      log.warn e.message
      @entries = []
      Yast::Popup.Message(e.message)
    end
  end
end
