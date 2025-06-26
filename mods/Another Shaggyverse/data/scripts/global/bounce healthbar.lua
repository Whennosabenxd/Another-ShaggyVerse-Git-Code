local iconosxd = 25
local p1y = 0
function createPost()
    p1y = get("iconP1.y")
end
function beatHit()
    if iconosxd == 25 then
        iconosxd = -25
    else
        iconosxd = 25
    end
    set("iconP1.angle", iconosxd*-1)
    set("iconP2.angle", iconosxd)
    set("iconP1.scale.x", 1)
    set("iconP2.scale.x", 1)
    set("iconP1.scale.y", 1)
    set("iconP2.scale.y", 1)
    if getProperty('iconP1', 'y') == p1y or getProperty('iconP1', 'y') == p1y+575 or getProperty('iconP1', 'y') == p1y-575 then
    if iconosxd == 25 then
    set("iconP1.y", get("iconP1.y")+10)
    set("iconP2.y", get("iconP2.y")-10)
    tweenActorProperty('iconP1', 'y', get("iconP1.y")-10, crochet*0.0008, 'quadOut')
    tweenActorProperty('iconP2', 'y', get("iconP2.y")+10, crochet*0.0008, 'quadOut')
    else
        set("iconP1.y", get("iconP1.y")-10)
        set("iconP2.y", get("iconP2.y")+10)
        tweenActorProperty('iconP1', 'y', get("iconP1.y")+10, crochet*0.0008, 'quadOut')
        tweenActorProperty('iconP2', 'y', get("iconP2.y")-10, crochet*0.0008, 'quadOut')
    end
    else
    end
end
function update(elapsed)
    if getProperty('iconP1', 'angle') == 25 or getProperty('iconP1', 'angle') == -25 then
        tweenActorProperty('iconP1', 'angle', 0, crochet*0.0008, 'quadOut')
        tweenActorProperty('iconP2', 'angle', 0, crochet*0.0008, 'quadOut')
    end
end