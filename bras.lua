
local http = require("socket.http")
local ltn12 = require("ltn12")
local socket = require("socket.core")

local modname = ...
local M = {}
if modname ~= nil then
    _G[modname] = M
end


--create connection with specified IP address
function create(ssrc)
    function realcreate()
        
        if ssrc == "*" then ssrc = "0.0.0.0" end
        sock,err = socket.tcp()
    
        err = "address error"

        if sock == nil then
            return nil,err
        end

        res,err = sock:bind(ssrc,0) -- zero means unbind port
    
        if nil == res then
            print("res nil")
            sock:close()
        else
            return sock
        end
    
        return nil,err
    end

    return realcreate
end


--all the data need to connect
local data = {}

data["action"] = "login"
data["username"] = ""
data["password"] = ""

local bindSrc = "*"


--data is a dict
function urlencode(data) 
    local str = ""
    for k,v in pairs(data) do
        str = str .. k.."="..v.."&"
    end
    --print(string.sub(str,0,-2))
    return string.sub(str,0,-2)

end

local post = urlencode(data)

function connectBras()
    local response = {}
    socket.http.request({
        method = "POST",
        url = 'http://p.nju.edu.cn/portal/portal_io.do',
        headers = {
            ["Referer"] = "http://p.nju.edu.cn/portal_io.do",
            ["Content-Length"] = string.len(post)
        },
        source = ltn12.source.string(post),
        sink = ltn12.sink.table(response),
        create = create(bindSrc),
    })
    return response
end
M["data"] = data
M['connectBras'] = connectBras
M["bindSrc"] = bindSrc


function connect()
    if arg[1] ~= nil then
        bindSrc = arg[1]
        --print.table.concat(connectBras())
    end
    print(table.concat(connectBras()))
end
if modname == nil then
    connect()
end

