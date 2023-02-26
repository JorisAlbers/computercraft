modem_side = "left"
level = 0

rednet.open(modem_side)

while true do
  os.pullEvent("redstone")
  rednet.broadcast("at_level:"..level)
end


