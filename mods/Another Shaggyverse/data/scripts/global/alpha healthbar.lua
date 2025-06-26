local disapear = true
function updatePost(elapsed)
        if getHealth() >= 2 then
        if disapear == true then
        tweenActorProperty('iconP1', 'alpha', 1, 0.6, 'quadOut')
        tweenActorProperty('iconP2', 'alpha', 1, 0.6, 'quadOut')
        tweenActorProperty('healthBar', 'alpha', 1, 0.6, 'quadOut')
        tweenActorProperty('healthBarBG', 'alpha', 1, 0.6, 'quadOut')
        disapear = false
        end
        elseif getHealth() < 2 and getHealth() > 0.8 then
        if disapear == false then
        tweenActorProperty('iconP1', 'alpha', 1, 0.6, 'quadIn')
        tweenActorProperty('iconP2', 'alpha', 1, 0.6, 'quadIn')
        tweenActorProperty('healthBar', 'alpha', 1, 0.6, 'quadIn')
        tweenActorProperty('healthBarBG', 'alpha', 1, 0.6, 'quadIn')
        disapear = true
        end
        elseif getHealth() <= 0.8 then
            if disapear == true then
            tweenActorProperty('iconP1', 'alpha', 0.4, 0.6, 'quadOut')
            tweenActorProperty('iconP2', 'alpha', 0.4, 0.6, 'quadOut')
            tweenActorProperty('healthBar', 'alpha', 0.4, 0.6, 'quadOut')
            tweenActorProperty('healthBarBG', 'alpha', 0.4, 0.6, 'quadOut')
            disapear = false
        end
    end
end