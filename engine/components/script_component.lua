local scriptComponent = {
    name = "script";
    enabled = true;
}

function scriptComponent.new() --FIXME This function does not seem to work
    return table.new(scriptComponent)
end

return scriptComponent