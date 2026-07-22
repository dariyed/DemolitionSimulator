local DestructionRequest = require("../../src/shared/Destruction/DestructionRequest")

return {
    ["accepts a request for the legal test target"] = function()
        local ok, err = DestructionRequest.validate({ partId = DestructionRequest.TEST_TARGET_ID })
        assert(ok, "expected the legal test target to be accepted, got error: " .. tostring(err))
    end,

    ["rejects a request for an arbitrary/unknown part id"] = function()
        local ok = DestructionRequest.validate({ partId = "SomeOtherPart" })
        assert(not ok, "expected an arbitrary part id to be rejected")
    end,

    ["rejects a request with a missing partId"] = function()
        local ok = DestructionRequest.validate({})
        assert(not ok, "expected a request with no partId to be rejected")
    end,

    ["rejects a request with a non-string partId"] = function()
        local ok = DestructionRequest.validate({ partId = 12345 })
        assert(not ok, "expected a non-string partId to be rejected")
    end,

    ["rejects a request that isn't a table"] = function()
        local ok = DestructionRequest.validate("not a table")
        assert(not ok, "expected a non-table request to be rejected")
    end,

    ["rejects nil"] = function()
        local ok = DestructionRequest.validate(nil)
        assert(not ok, "expected nil to be rejected")
    end,
}
