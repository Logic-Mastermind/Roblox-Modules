local module = {}
local LocalPlayer = game:GetService("Players").LocalPlayer;
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local TweenService = game:GetService("TweenService");
local Modules = require(ReplicatedStorage.Modules);
local Promise = require(ReplicatedStorage.Promise);
local Templates = ReplicatedStorage.Templates;
local Assets = ReplicatedStorage.Assets;

local Menu = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Menu");
local Viewport = Menu.Viewport;
local Popups = Viewport.Popups;

function module.toggleFade(value)
	local fadeUi = Viewport.Fade;
	local val = value;
	if (value == nil) then val = not fadeUi:GetAttribute("Enabled") end;
	
	fadeUi.Visible = val;
	Modules.fade(fadeUi, 0.3, Modules.ternary(val, "in", "out"));
	fadeUi:SetAttribute("Enabled", val);
end

function module.createModal(title, desc)
	local modal = Templates.Modal:Clone();
	module.toggleFade();
	
	modal.Title.Text = title;
	modal.Description.Text = desc or "";
	modal.Confirm:Destroy();
	modal.Parent = Popups;
	
	return Promise.new(function(resolve)
		modal.Deny.MouseButton1Click:Connect(function()
			Assets.UISounds.Click:Play();
			module.toggleFade();
			modal:Destroy();
			resolve(1);
		end)

		modal.Allow.MouseButton1Click:Connect(function()
			Assets.UISounds.Click:Play();
			module.toggleFade();
			modal:Destroy();
			resolve(2);
		end)
	end)
end

function module.createInfoModal(title, desc)
	local modal = Templates.Modal:Clone();
	module.toggleFade();
	
	modal.Deny:Destroy();
	modal.Allow:Destroy();
	modal.Title.Text = title;
	modal.Description.Text = desc or "";
	modal.Parent = Popups;

	return Promise.new(function(resolve)
		modal.Confirm.MouseButton1Click:Connect(function()
			Assets.UISounds.Click:Play();
			module.toggleFade();
			modal:Destroy();
			resolve(0);
		end)
	end)
end

function module.toggleModal(modal, value)
	local val = value;
	if (value == nil) then
		local enabled = modal:GetAttribute("Enabled");
		if (enabled == nil) then val = true
		else val = not enabled end;
	end
	
	modal.Visible = val;
	module.toggleFade(val);
	modal:SetAttribute("Enabled", val);
end

function module.createPrompt(text, timeout)
	local prompt = Templates.NotifPrompt:Clone();
	prompt.Display.Text = text;
	prompt.Parent = Popups
	
	module.addToNotifPanel(prompt, timeout);
	return Promise.new(function(resolve)
		prompt.Confirm.MouseButton1Click:Connect(function()
			if (prompt.Confirm.BackgroundTransparency == 0.5) then return end;
			Assets.UISounds.Click:Play();
			Modules.toggleUI(prompt, false, true);
			resolve(1)
		end)
		
		prompt.Deny.MouseButton1Click:Connect(function()
			if (prompt.Deny.BackgroundTransparency == 0.5) then return end;
			Assets.UISounds.Click:Play();
			Modules.toggleUI(prompt, false, true);
			resolve(2);
		end)
	end)
end

function module.createNotif(msg, timeout)
	local clone = Templates.InfoWarning:Clone();
	clone.Display.Text = msg;
	clone.Parent = Popups;
	
	module.addToNotifPanel(clone, timeout);
end

function module.addToNotifPanel(ui, timeout)
	timeout = timeout or 3;
	local goal = UDim2.new(0.72, 0, 0.95, 0);
	local lastPopup: Frame = Popups:FindFirstChild("LastInfoWarning");
	if (lastPopup) then
		ui.Position = lastPopup.Position;
		goal = UDim2.new(0.72, 0, lastPopup.Position.Y.Scale - 0.08, 0);
		lastPopup.Name = "InfoWarning";
	end

	ui.Name = "LastInfoWarning";
	local tween = TweenService:Create(ui, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = goal });
	tween:Play();

	tween.Completed:Connect(function()
		Modules.tween(ui.TimeoutBar, TweenInfo.new(timeout), { Size = UDim2.new(0, 0, 0.04, 0) }):andThen(function()
			local fade = Modules.fade(ui, 1, "out", true);
			fade:awaitStatus();
			ui:Destroy();
		end)
	end)
end
return module
