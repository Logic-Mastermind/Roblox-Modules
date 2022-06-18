local TweenService = game:GetService("TweenService");
local Promise = require(game:GetService("ReplicatedStorage").Promise);
local module = {};

module.string = {};
module.array = {};

function module.tween(instance, info, props)
	return Promise.new(function(resolve, reject, onCancel)
		local tween = TweenService:Create(instance, info, props);
		
		onCancel(function()
			tween:Cancel();
		end)
		
		tween.Completed:Connect(resolve);
		tween:Play();
	end)
end

function module.fade(ui, duration, direction, props)
	local goal = {};
	local goalNum = module.ternary(typeof(direction) == "string", module.ternary(direction == "in", 0, 1), direction);
	
	for i,v in ipairs(props) do
		goal[v] = goalNum;
	end
	
	return module.tween(ui, TweenInfo.new(duration, Enum.EasingStyle.Linear), goal);
end

function module.ternary(cond: boolean, t: any, f: any)
	if (cond) then
		if (type(t) == "function") then return t()
		else return t end;
	else
		if (type(f) == "function") then return f()
		else return f end;
	end
end

function module.toggleButton(button: TextButton|ImageButton, enabled: boolean)
	local value = module.ternary(enabled, 0, 0.5);
	for _,v in ipairs(button:getChildren()) do
		if (module.string.startsWith(v.Name, "UI")) then continue end;
		
		if (string.find(v.ClassName, "Text")) then v.TextTransparency = value end;
		if (v:FindFirstChild("Display")) then v:FindFirstChild("Display").Transparency = value end;
		if (string.find(v.ClassName, "Button")) then v.BackgroundTransparency = value; v.AutoButtonColor = enabled end;
	end
	
	button.Transparency = value;
	if (string.find(button.ClassName, "Button")) then button.AutoButtonColor = enabled end;
end

function module.tweenModel(model, tweenInfo, cframe)
	if (model:GetAttribute("InAction"))  then return end
	
	local CFrameValue = Instance.new("CFrameValue");
	CFrameValue.Value = model:GetPrimaryPartCFrame();
	
	model:SetAttribute("InAction", true);
	CFrameValue:GetPropertyChangedSignal("Value"):Connect(function()
		model:SetPrimaryPartCFrame(CFrameValue.Value);
	end)

	local tween = TweenService:Create(CFrameValue, tweenInfo, { Value = cframe });
	tween:Play();

	tween.Completed:Connect(function()
		CFrameValue:Destroy();
		model:SetAttribute("InAction", false);
	end)
	
	return tween;
end

function module.string.startsWith(str, start)
	return str:sub(1, #start) == start;
end

function module.string.endsWith(str, ending)
	return str:sub(-#ending) == ending;
end

function module.string.split(s, delimiter)
	local result = {};
	for match in (s..delimiter):gmatch("(.-)"..delimiter) do
		table.insert(result, match);
	end
	return result;
end

function module.array.map(tbl, f)
	local t = {};
	for k,v in ipairs(tbl) do
		t[k] = f(v);
	end
	return t;
end

return module;
