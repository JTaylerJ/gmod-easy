# gmod-easy
Gmod lib for easy coding
## Include:
- Network Libs
- Formatter(OLD)
## Wait Uploading:
- UI (MultiScreen Size)
## Plans:
- Panel (Text Creations)
  ```lua
  local title_var = "Example Title"
  local panel = vgui.CreateT([[
  <block id:frame dock:FILL style:default>
    <block id:top_panel dock:TOP:10px> 
      <text id:title text:@title_var>
        DoClick = function(self)
          print("doclick")
        end
      </text>
    </block>
  </block> ]])
  panel.frame.top_panel.Paint = ui.paints.fill(Color(255,0,0))
  ```


# Network Lib
Network Library __(IN DEV)__\
Using tag nw_ and nwv_ to make server-client sync variables
```lua
if SERVER then
  ply.nw_rank = "superadmin"
  ply.nwv_testvar = "Hello World"
  print(ply.nw_rank) --> superadmin
  print(ply.testvar) --> Hello World
end

if CLIENT then
  ply.nw_rank = "owner" --> make requests to server on change vars
end
```


Example using:
```lua
if CLIENT then
  concommand.Add("make_me_superadmin", function(ply)
    ply.nw_usergroup = "superadmin"
    timer.Simple(1, function()
      print(ply.nw_usergroup) --> superadmin
    end)
  end
end
if SERVER then
  hook.Add("easy.libs.network.nw:usergroup", "givesuperadmin", function(ply, key, value)
    if ply:Steam64() == "7681500000000" then return true end
    if ply:Steam64() == "7681500000000" then return true, "admin" end
  end)
end
```
>### My Contacts:
>- Discord: -243 King#6354
