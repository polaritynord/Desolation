local scriptComponent = {
    name = "script";
    enabled = true;
}

function scriptComponent.new()
    return table.new(scriptComponent)
end

return scriptComponent