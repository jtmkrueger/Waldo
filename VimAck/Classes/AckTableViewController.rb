#
#  AckTableViewController.rb
#  Waldo
#
#  Copyright 2011 Majd Taby. All rights reserved.
#

# AckTableViewController acts as the DataSource and the Delegate to the 
# main NSOutlineView which shows the results o the search.
#
class AckTableViewController
    
    # table_view - Outlet to the NSOutlineView instance
    # records - An Array of MatchedFile objects generated by AckWindowController
    # projectRoot - The path to the project which launched this instance of Waldo
    attr_accessor :table_view, :records, :projectRoot
    
    def initialize
        @records = {}
    end
    
    ## NSTableDataSource methods
    
    # item being null means it's asking for the root element
    def outlineView(outlineView, numberOfChildrenOfItem:item)
        return (item == nil) ? @records.length : item.records.length;
    end
    
    # MatchedFile items are expandable
    def outlineView(outlineView, isItemExpandable:item)
        return (item.instance_of? MatchedFile) ? true : false;
    end
    
    # item being null means it's asking for the root element
    def outlineView(outlineView, child:index, ofItem:item)
        if item == nil
            @records[index]
        else
            ret = item.records[index]
            ret
        end
    end 
    
    def outlineView(outlineView, objectValueForTableColumn:tableColumn, byItem:item)
        
        # For MatchedFile items, separate the path from the filename
        if item.instance_of? MatchedFile
            
            path = File.path item.filename
            separater = " - "
            base = File.basename item.filename
            
            styledString = NSMutableAttributedString.alloc.initWithString "#{base}#{separater}#{path}"
            
            styledString.addAttribute(NSFontAttributeName,
                                      value: NSFont.systemFontOfSize(11),
                                      range: [0,styledString.length])
            
        # For MatchedLine items, display the match in black, bold, rest in gray
        else
            styledString = NSMutableAttributedString.alloc.initWithString item.matched_line
            
            
            styledString.addAttribute(NSForegroundColorAttributeName,
                                      value: NSColor.grayColor,
                                      range: [0,styledString.length])
            
            styledString.addAttribute(NSFontAttributeName,
                                      value: NSFont.systemFontOfSize(11),
                                      range: [0,styledString.length])
            
            item.matched_ranges.each do |range|
                
                styledString.addAttribute(NSFontAttributeName,
                                          value: NSFont.boldSystemFontOfSize(11),
                                          range:[range,item.query.length])
                
                styledString.addAttribute(NSForegroundColorAttributeName,
                                          value: NSColor.blackColor,
                                          range:[range,item.query.length])
            end
            
        end
        
        styledString
    end
    
    def outlineView(outlineView, willDisplayCell:cell, forTableColumn:tableColumn, item:item)
        cell.setRepresentedObject(item)
    end
    
    def tableView(tableView, willDisplayCell:cell, forTableColumn:column, row:row)
        cell.setRepresentedObject(@records[row])
    end
    
    def outlineViewSelectionDidChange(notification)
        rowNumber = notification.object.selectedRow
        item = notification.object.itemAtRow(rowNumber)
        
        return if not item.instance_of? MatchedLine
        
        fullPath = "#{@projectRoot}/#{item.filename}"
		lineNumber = item.line_number
		columnNumber = item.matched_ranges[0] + 1
		
		url = NSURL.URLWithString("mvim://open?url=file://#{fullPath}&line=#{lineNumber}&column=#{columnNumber}")
		NSWorkspace.sharedWorkspace.openURL(url)
    end
        
end