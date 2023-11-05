local pluginName     = select(1,...);
local componentName  = select(2,...);
local signalTable    = select(3,...);
local my_handle      = select(4,...);
----------------------------------------------------------------------------------------------------------------

local PlugTitle = "Timecode BPM convert"

local messageDescription =  "USE WITH CAUTION, TAKE BACKUPS.\n\n"..
                            "This tool will convert all the events on all your tracks in your timecode.\n\n"..
                            "The tool automagically convert BPM to the correct rate and moves all the data on the timeline\n\n"..
                            "It will create a new timecode object so you wont loose the source timeline"


-- Almost never tested

-- Github: https://github.com/kinglevel
-- Please commit or post updates for the community.


--[[
                      /mMNh-
                      NM33My
                      -ydds`
                        /.
                        ho
         +yy/          `Md           +yy/
        .N33N`         +MM.         -N33N`
         -+o/          hMMo          o++-
            d:        `MMMm         oy
-:.         yNo`      +MMMM-       yM+        .:-`
d33N:       /MMh.     dMMMMs     -dMM.       :N33d
+ddd:       `MMMm:   .MMMMMN    /NMMd        :hdd+
  ``hh+.     hMMMN+  +MMMMMM: `sMMMMo     -ody `
    -NMNh+.  +MMMMMy`d_SUM_My.hMMMMM-  -odNMm`
     /MMMMNh+:MMMMMMmMMMMMMMNmMMMMMN-odNMMMN-
      oMMMMMMNMMMMMMMMMMMMMMMMMMMMMMNMMMMMM/
       hMMMMMMMMM---LEDvard---MMMMMMMMMMMMo
       `mMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMh
        .NMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMm`
         :mmmmmmmmmmmmmmmmmmmmmmmmmmmmmm-
        `://////////////////////////////.
    -+ymMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNho/.

"Vision will blind. Severance ties. Median am I. True are all lies"

]]--






-- Confirm
local function ConfirmBox(displayHandle, message)
	if Confirm(PlugTitle, message) then
		return true
	else
		return false
	end
end





-- Main window for user options
local function BPMsettings(displayHandle)

  local options = {
      title=PlugTitle,
      backColor="Global.Focus",
      icon="invert",

      message=messageDescription,

      display= nil,

      commands={
          {value=0, name="Abort"},
          {value=1, name="Convert"}
      },

      inputs={
          {name="Timecode Source", value="", blackFilter="", whiteFilter="0123456789"},
          {name="Timecode Destination", value="", blackFilter="", whiteFilter="0123456789"},
          {name="BPM Destination", value="", blackFilter="", whiteFilter="0123456789"},
          {name="BPM Original", value="", blackFilter="", whiteFilter="0123456789"}
      }
  }

  -- spawn main window
  local userinput = MessageBox(options)

  local confirm = userinput.result


  -- Abort
  if confirm == 0 then
      Printf("Aborted by user")
      return false
  end


  -- Push parameters
   if confirm == 1 then
      --get all variables from the user
      local BPMoriginal = userinput.inputs["BPM Original"]
      local BPMdestination = userinput.inputs["BPM Destination"]
      local Timecode = userinput.inputs["Timecode Source"]
      local TimecodeDst = userinput.inputs["Timecode Destination"]

      --Proceed if all the needed data is present
      if tonumber(BPMoriginal) ~= nil and tonumber(BPMdestination) ~= nil and tonumber(Timecode) ~= nil then
        speedfactor = BPMdestination / BPMoriginal

        return speedfactor, Timecode, TimecodeDst
      else
        Printf("Missing data")
        return false
      end

      return false
  end
end







local function EventTypes(o, maxDepth)
  --Modified GMA3helper:tree
  --Made for seeeing classes easier

  local function printDirectory(dir, prefix, depth)
      local i = 1;
      if maxDepth then 
          if (depth > maxDepth) then return; end
      end
      while dir[i] do
          local content = dir[i]
          Printf(prefix..'|---'..content.index..': '..content.name..': '..content:GetClass())

          printDirectory(content,prefix..'|   ', depth+1) -- use recursion
          i = i + 1;
      end
  end
  printDirectory(o,'',1)
end








local function BPMConvert(obj, rate)
  --Modified GMA3helper:tree

  local function printDirectory(dir, prefix, depth)
      local i = 1;
      while dir[i] do
          local content = dir[i]
          --Get all the intresting event classes
          if content:GetClass() == "FaderEvent" or content:GetClass() == "CmdEvent" then
            --Get the Times
            local time = content:Get("TIME")
            --Set the Times
            content:Set("TIME", time * rate)
          end
          
          printDirectory(content,prefix..'|   ', depth+1) -- use recursion
          i = i + 1;
      end
  end

  printDirectory(obj,'',1)

end






local function Convert(displayHandle)
  --Get all settings from the user
  local speedfactor, timecodeSrc, timecodeDst = BPMsettings(displayHandle)

  --Confirm the settings
  local confirm = ConfirmBox(displayHandle, "Do you really want to convert all events on\n"..
                              "Timecode: \n" .. 
                              timecodeSrc .. " --- " .. DataPool().Timecodes[tonumber(timecodeSrc)].name ..
                              "\nRate: \n" ..
                              speedfactor)

  
  if confirm == true then
    --Make backup
    Cmd("ClearAll")
    local X = Cmd("Copy timecode " .. timecodeSrc .. " at timecode " .. timecodeDst)
    --If backup is ok and nothing in the way
    if X == "OK" then
      --Get timecode object
      local song = DataPool().Timecodes[tonumber(timecodeDst)]
      --Rate
      local rate = tonumber(speedfactor)
      --Magic like Harry Potter
      BPMConvert(song, rate)
      Cmd("Select timecode " .. timecodeDst)
    end
  end

end



local function main(displayHandle)

  Convert(displayHandle)

end






return main