local infiniteScoreNotifs = ENGINE_COMPONENTS.scriptComponent.new()

local function drawNotifs(comp)
    for _, v in ipairs(comp.parent.notifs) do
        SetFont("desolation/assets/fonts/disposable-droid.ttf", 24)
        love.graphics.setColor(v.color)
        love.graphics.printf(v.text, v.position[1], v.position[2], 1000, "center")
    end
end

function infiniteScoreNotifs:newNotif(text)
    local notif = {
        text = text;
        position = {-10, 370};
        color = {1, 1, 1, 1};
        index = #self.parent.notifs+1;
        timer = 0;
    }
    self.parent.notifs[#self.parent.notifs+1] = notif
end

function infiniteScoreNotifs:load()
    self.parent.notifs = {}
    self.parent.imageComponent.draw = drawNotifs
end

function infiniteScoreNotifs:update(delta)
    --Update notifs
    for i, v in ipairs(self.parent.notifs) do
        --Scale & position
        local expectedY = 370 + (#self.parent.notifs-v.index)*24
        v.position[2] = v.position[2] + (expectedY-v.position[2])*16*delta
        --Timer & fading out
        v.timer = v.timer + delta
        if v.timer > 2.5 then
            v.color[4] = v.color[4] - 4*delta
            if v.color[4] < 0 then
                table.remove(self.parent.notifs, i)
                --TODO change index of upper(newer) notifs
                for k = i, #self.parent.notifs do
                    self.parent.notifs[k].index = self.parent.notifs[k].index - 1
                end
            end
        end
    end
end

return infiniteScoreNotifs