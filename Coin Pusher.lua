local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "COIN PUSHER [Alpha1.1]",
   LoadingTitle = "Loading...",
   LoadingSubtitle = "by YourBae",
})

local Tab = Window:CreateTab("Main")

local Remote = game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("SendDropItem")
local running = false

Tab:CreateToggle({
   Name = "Barrier Toggle",
   CurrentValue = false,
   Flag = "BarrierToggle",
   Callback = function(value)
      running = value
      if running then
         task.spawn(function()
            while running do
               Remote:FireServer({"Barrier", 1127})
               task.wait(0.1)
            end
         end)
      end
   end,
})
