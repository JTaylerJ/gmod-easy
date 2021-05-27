easy()

meta_function.__tostring = function(self)
    return "func: " .. debug.getinfo(self)["source"]
end