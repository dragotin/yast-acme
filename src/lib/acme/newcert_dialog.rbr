# Copyright (c) 2014 SUSE LLC.
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
require "byebug"
require "set"

Yast.import "UI"

module Lectl
  # Dialog allowing the user to set the arguments used to display the journal
  # entries in ACME::EntriesDialog
  #
  # @see ACME::EntriesDialog
  class NewCertDialog

    include Yast::UIShortcuts
    include Yast::I18n

    INPUT_WIDTH = 20

    def initialize()
      textdomain "acme"
      
      @hostnames = []
    end

    # Displays the dialog
    def run
      return nil unless create_dialog
      begin
        return event_loop
      ensure
        Yast::UI.CloseDialog
      end
    end

  private
  
    def event_loop
      loop do
        case input = Yast::UI.UserInput
        when :cancel
          break
        when :ok
          create_new_cert
          break
        when :remove
          remove_hostname  
        when :add 
          add_hostname  
        else
          raise "Unexpected input #{input}"
        end
      end
    end

    def add_hostname
      newname  = Yast::UI.QueryWidget(Id(:newhostname), :Value)
      oldnames = Yast::UI.QueryWidget(Id(:hostnames), :Items)
#      if Buildins. oldnames.include?(newname)
#        
#
#      end
      oldnames = oldnames << newname
      Yast::UI.ChangeWidget(Id(:hostnames), :Items, oldnames)
      Yast::UI.ChangeWidget(Id(:newhostname), :Value, "")
    end 
    
    def remove_hostname
      values = Yast::UI.QueryWidget(Id(:hostnames), :Items) - [Yast::UI.QueryWidget(Id(:hostnames), :Value)]
      Yast::UI.ChangeWidget(Id(:hostnames), :Items, values)
    end
    
    # Translates the value of the widgets to a new QueryPresenter object
    def create_new_cert
      nil
    end

    # Draws the dialog
    def create_dialog
      Yast::UI.OpenDialog(
        VBox(
          # Header
          Heading("Create new Certificate"),
             
          HBox(
            InputField(Id(:newhostname), Opt(:hstretch), "", ""),
            PushButton(Id(:add), Yast::Label.AddButton)
          ),
             
          HBox(
            SelectionBox(Id(:hostnames), "Valid for Hostnames:", []),
            VBox(
              PushButton(Id(:remove),    Yast::Label.RemoveButton),
              VStretch()
            )
          ),
          VSpacing(0.3),

          # Footer buttons
          ButtonBox(
            PushButton(Id(:cancel), Yast::Label.CancelButton),
            PushButton(Id(:ok),     Yast::Label.OKButton)
          )
        )
      )
    end
  end
end

