#!/usr/bin/env lua
-- If this variable is true, then strict type checking is performed for all
-- operations. This may result in slower code, but it will allow you to catch
-- errors and bugs earlier.
local strict = true

--------------------------------------------------------------------------------

local bigint = {}
setmetatable(bigint, {__call = function(_, arg) return bigint.new(arg) end})

local digit_block_size = 7
local max_size = 10 ^ digit_block_size

local mt = {
    __add = function(lhs, rhs)
        return bigint.add(lhs, rhs)
    end,
    __unm = function(arg)
        return bigint.negate(arg)
    end,
    __sub = function(lhs, rhs)
        return bigint.subtract(lhs, rhs)
    end,
    __mul = function(lhs, rhs)
        return bigint.multiply(lhs, rhs)
    end,
    __div = function(lhs, rhs)
        return bigint.divide(lhs, rhs)
    end,
    __mod = function(lhs, rhs)
        return bigint.modulus(lhs, rhs)
    end,
    __pow = function(lhs, rhs)
        return bigint.exponentiate(lhs, rhs)
    end,
    __tostring = function(arg)
        return bigint.unserialize(arg, "s")
    end,
    __eq = function(lhs, rhs)
        return bigint.compare(lhs, rhs, "==")
    end,
    __lt = function(lhs, rhs)
        return bigint.compare(lhs, rhs, "<")
    end,
    __le = function(lhs, rhs)
        return bigint.compare(lhs, rhs, "<=")
    end
}

local named_powers = require("libs.bigint.named-powers-of-ten")

-- Create a new bigint or convert a number or string into a big
-- Returns an empty, positive bigint if no number or string is given
function bigint.new(num)
    local self = {
        sign = "+",
        digits = {},
        dense = true
    }

    -- Return a new bigint with the same sign and digits
    function self:clone()
        local newint = bigint.new()
        newint.sign = self.sign
        newint.dense = self.dense
        for _, digit in pairs(self.digits) do
            newint.digits[#newint.digits + 1] = digit
        end
        return newint
    end

    setmetatable(self, mt)

    if (num) then
        local num_string = tostring(num)
        for digit in string.gmatch(num_string, "[0-9]") do
            table.insert(self.digits, tonumber(digit))
        end
        local digits_table = {}
        for i = 1, #self.digits do
            local tbl_idx = math.ceil(#self.digits / digit_block_size) - math.floor((#self.digits - i) / digit_block_size)
            -- print(tbl_idx, i, self.digits[i])
            local digit = self.digits[i]
            digits_table[tbl_idx] = (digits_table[tbl_idx] or "")..tostring(digit)
        end
        for index, value in ipairs(digits_table) do
            digits_table[index] = tonumber(value)
            -- io.write(digits_table[index], ":", index, "   ")
        end
        -- io.write("\n")
        self.digits = digits_table
        if string.sub(num_string, 1, 1) == "-" then
            self.sign = "-"
        end
    end

    return bigint.strip(self)
end
-- Check the type of a big
-- Normally only runs when global variable "strict" == true, but checking can be
-- forced by supplying "true" as the second argument.
function bigint.check(big, force)
    if (strict or force) then
        assert(getmetatable(big) == mt, "at least one arg is not a bigint")
        assert(#big.digits > 0, "bigint is empty")
        assert(big.sign == "+" or big.sign == "-", "bigint is unsigned")
        for _, digit in pairs(big.digits) do
            assert(type(digit) == "number", "at least one digit is invalid")
            assert(digit < max_size and digit >= 0, digit .. " is not between 0 and "..max_size-1)
            assert(math.floor(digit) == digit, digit .. " is not an integer")
        end
    end
    return true
end

-- Strip leading zeroes from a big, but don't remove the last zero
function bigint.strip(big)
	while (#big.digits > 1) and (big.digits[1] == 0) do
        table.remove(big.digits, 1)
    end
	return big
end

-- Return a new big with the same digits but with a positive sign (absolute
-- value)
function bigint.abs(big)
    bigint.check(big)
    local result = big:clone()
    result.sign = "+"
    return result
end

-- Return a new big with the same digits but the opposite sign (negation)
function bigint.negate(big)
    bigint.check(big)
    local result = big:clone()
    if (result.sign == "+") then
        result.sign = "-"
    else
        result.sign = "+"
    end
    return result
end

-- Return the number of digits in the big
function bigint.digits(big)
    bigint.check(big)
    return #big.digits
end

-- Convert a big to a number or string
function bigint.unserialize(big, output_type, precision)
    bigint.check(big)

    local num = ""
    if big.sign == "-" then
        num = "-"
    end


    if ((output_type == nil)
    or (output_type == "number")
    or (output_type == "n")
    or (output_type == "string")
    or (output_type == "s")) then
        -- Unserialization to a string or number requires reconstructing the
        -- entire number

        for id, digit in pairs(big.digits) do
            if id ~= 1 then
                num = num .. string.format("%0"..digit_block_size.."d", digit)
            else
                num = num .. math.floor(digit) -- lazy way of getting rid of .0$
            end
        end

        if ((output_type == nil)
        or (output_type == "number")
        or (output_type == "n")) then
            return tonumber(num)
        else
            return num
        end

    else
        -- Unserialization to human-readable form or scientific notation only
        -- requires reading the first few digits
        if (precision == nil) then
            precision = math.min(#big.digits, 3)
        else
            assert(precision > 0, "Precision cannot be less than 1")
            assert(math.floor(precision) == precision,
                   "Precision must be a positive integer")
        end

        -- num is the first (precision + 1) digits, the first being separated by
        -- a decimal point from the others
        local str = tostring(math.floor(big.digits[1]))
        local str_iterator = 1
        while #str < precision do
            str_iterator = str_iterator + 1
            str = str .. string.format("%0"..digit_block_size.."d", big.digits[str_iterator])
        end
        str = str:sub(1, precision)
        num = num .. str:sub(1, 1)
        if (precision > 1) then
            num = num .. "." .. str:sub(2)
        end

        local num_len = big.digits[1] > 0 and math.floor(math.log10(big.digits[1])) or 0
        if #big.digits > 1 then
            num_len = num_len + (#big.digits - 1) * digit_block_size
        end
        if ((output_type == "human-readable")
        or (output_type == "human")
        or (output_type == "h"))
        and (num_len >= 3 and num_len <= 10002) then
            -- Human-readable output contributed by 123eee555

            local name
            local walkback = 0 -- Used to enumerate "ten", "hundred", etc

            -- Walk backwards in the index of named_powers starting at the
            -- number of digits of the input until the first value is found
            for i = (num_len), (num_len - 3), -1 do
                name = named_powers[i]
                if (name) then
                    if (walkback == 1) then
                        name = "ten " .. name
                    elseif (walkback == 2) then
                        name = "hundred " .. name
                    end
                    break
                else
                    walkback = walkback + 1
                end
            end

            return num .. " " .. name

        else
            return num .. "*10^" .. (num_len)
        end

    end
end

-- Basic comparisons
-- Accepts symbols (<, >=, ~=) and Unix shell-like options (lt, ge, ne)
function bigint.compare(big1, big2, comparison)
    bigint.check(big1)
    bigint.check(big2)

    local greater = false -- If big1.digits > big2.digits
    local equal = false

    if (big1.sign == "-") and (big2.sign == "+") then
        greater = false
    elseif (#big1.digits > #big2.digits)
    or ((big1.sign == "+") and (big2.sign == "-")) then
        greater = true
    elseif (#big1.digits == #big2.digits) then
        -- Walk left to right, comparing digits
        for digit = 1, #big1.digits do
            if (big1.digits[digit] > big2.digits[digit]) then
                greater = true
                break
            elseif (big2.digits[digit] > big1.digits[digit]) then
                break
            elseif (digit == #big1.digits)
                   and (big1.digits[digit] == big2.digits[digit]) then
                equal = true
            end
        end

    end

    -- If both numbers are negative, then the requirements for greater are
    -- reversed
    if (not equal) and (big1.sign == "-") and (big2.sign == "-") then
        greater = not greater
    end

    return (((comparison == "<") or (comparison == "lt"))
            and ((not greater) and (not equal)) and true)
        or (((comparison == ">") or (comparison == "gt"))
            and ((greater) and (not equal)) and true)
        or (((comparison == "==") or (comparison == "eq"))
            and (equal) and true)
        or (((comparison == ">=") or (comparison == "ge"))
            and (equal or greater) and true)
        or (((comparison == "<=") or (comparison == "le"))
            and (equal or not greater) and true)
        or (((comparison == "~=") or (comparison == "!=") or (comparison == "ne"))
            and (not equal) and true)
        or false
end

-- BACKEND: Add big1 and big2, ignoring signs
function bigint.add_raw(big1, big2)
    bigint.check(big1)
    bigint.check(big2)

    local result = bigint.new()
    local max_digits = 0
    local carry = 0

    if (#big1.digits >= #big2.digits) then
        max_digits = #big1.digits
    else
        max_digits = #big2.digits
    end

    -- Walk backwards right to left, like in long addition
    for digit = 0, max_digits - 1 do
        local sum = (big1.digits[#big1.digits - digit] or 0)
                  + (big2.digits[#big2.digits - digit] or 0)
                  + carry

        if (sum >= max_size) then
            carry = 1
            sum = sum - max_size
        else
            carry = 0
        end

        result.digits[max_digits - digit] = sum
    end

    -- Leftover carry in cases when #big1.digits == #big2.digits and sum > 10, ex. 7 + 9
    if (carry == 1) then
        table.insert(result.digits, 1, 1)
    end

    return result

end

-- BACKEND: Subtract big2 from big1, ignoring signs
function bigint.subtract_raw(big1, big2)
    -- Type checking is done by bigint.compare
    assert(bigint.compare(bigint.abs(big1), bigint.abs(big2), ">="),
           "Size of " .. bigint.unserialize(big1, "string") .. " is less than "
           .. bigint.unserialize(big2, "string"))

    local result = big1:clone()
    local max_digits = #big1.digits
    local borrow = 0

    -- Logic mostly copied from bigint.add_raw ---------------------------------
    -- Walk backwards right to left, like in long subtraction
    for digit = 0, max_digits - 1 do
        local diff = (big1.digits[#big1.digits - digit] or 0)
                   - (big2.digits[#big2.digits - digit] or 0)
                   - borrow

        if (diff < 0) then
            borrow = 1
            diff = diff + max_size
        else
            borrow = 0
        end

        result.digits[max_digits - digit] = diff
    end
    ----------------------------------------------------------------------------


    return bigint.strip(result)
end

-- FRONTEND: Addition and subtraction operations, accounting for signs
function bigint.add(big1, big2)
    -- Type checking is done by bigint.compare

    local result

    -- If adding numbers of different sign, subtract the smaller sized one from
    -- the bigger sized one and take the sign of the bigger sized one
    if (big1.sign ~= big2.sign) then
        if (bigint.compare(bigint.abs(big1), bigint.abs(big2), ">")) then
            result = bigint.subtract_raw(big1, big2)
            result.sign = big1.sign
        else
            result = bigint.subtract_raw(big2, big1)
            result.sign = big2.sign
        end

    elseif (big1.sign == "+") and (big2.sign == "+") then
        result = bigint.add_raw(big1, big2)

    elseif (big1.sign == "-") and (big2.sign == "-") then
        result = bigint.add_raw(big1, big2)
        result.sign = "-"
    end

    return result
end

function bigint.subtract(big1, big2)
    -- Type checking is done by bigint.compare in bigint.add
    -- Subtracting is like adding a negative
    local big2_local = big2:clone()
    if (big2.sign == "+") then
        big2_local.sign = "-"
    else
        big2_local.sign = "+"
    end
    return bigint.add(big1, big2_local)
end

-- BACKEND: Multiply a big by a single digit big, ignoring signs
function bigint.multiply_single(big1, big2)
    bigint.check(big1)
    bigint.check(big2)
    assert(#big2.digits == 1, bigint.unserialize(big2, "string")
                              .. " has more than one digit")

    local result = bigint.new()
    local carry = 0

    -- Logic mostly copied from bigint.add_raw ---------------------------------
    -- Walk backwards right to left, like in long multiplication
    for digit = 0, #big1.digits - 1 do
        local this_digit = big1.digits[#big1.digits - digit]
                         * big2.digits[1]
                         + carry
        if (this_digit >= max_size) then
            carry = math.floor(this_digit / max_size)
            this_digit = this_digit - (carry * max_size)
        else
            carry = 0
        end

        result.digits[#big1.digits - digit] = this_digit
    end

    -- Leftover carry in cases when big1.digits[1] * big2.digits[1] > 0
    if (carry > 0) then
        table.insert(result.digits, 1, carry)
    end
    ----------------------------------------------------------------------------

    return result
end

-- FRONTEND: Multiply two bigs, accounting for signs
function bigint.multiply(big1, big2)
    -- Type checking done by bigint.multiply_single

    local result = bigint.new(0)
    local larger, smaller -- Larger and smaller in terms of digits, not size

    if (bigint.unserialize(big1) == 0) or (bigint.unserialize(big2) == 0) then
        return result
    end

    if (#big1.digits >= #big2.digits) then
        larger = big1
        smaller = big2
    else
        larger = big2
        smaller = big1
    end

    -- Walk backwards right to left, like in long multiplication
    for digit = 0, #smaller.digits - 1 do
        -- Sorry for going over column 80! There's lots of big names here
        local this_digit_product = bigint.multiply_single(larger,
                                                          bigint.new(smaller.digits[#smaller.digits - digit]))

        -- "Placeholding zeroes"
        if (digit > 0) then
            for placeholder = 1, digit do
                table.insert(this_digit_product.digits, 0)
            end
        end

        result = bigint.add(result, this_digit_product)
    end

    if (larger.sign == smaller.sign) then
        result.sign = "+"
    else
        result.sign = "-"
    end

    return result
end

-- Raise a big to a positive integer or big power (TODO: negative integer power)
function bigint.exponentiate(big, power)
    -- Type checking for big done by bigint.multiply
    assert(bigint.compare(power, bigint.new(0), ">="),
           "negative powers are not supported")
    local exp = power:clone()

    if (bigint.compare(exp, bigint.new(0), "==")) then
        return bigint.new(1)
    elseif (bigint.compare(exp, bigint.new(1), "==")) then
        return big:clone()
    else
        local result = bigint.new(1)
        local base = big:clone()

        while (true) do
            if (bigint.compare(
                bigint.modulus(exp, bigint.new(2)), bigint.new(1), "=="
            )) then
                result = bigint.multiply(result, base)
            end
            if (bigint.compare(exp, bigint.new(1), "==")) then
                break
            else
                exp = bigint.divide(exp, bigint.new(2))
                base = bigint.multiply(base, base)
            end
        end

        return result
    end

end

-- BACKEND: Divide two bigs (decimals not supported), returning big result and
-- big remainder
-- WARNING: Only supports positive integers
function bigint.divide_raw(big1, big2)
    -- Type checking done by bigint.compare
    if (bigint.compare(big1, big2, "==")) then
        return bigint.new(1), bigint.new(0)
    elseif (bigint.compare(big1, big2, "<")) then
        return bigint.new(0), big1:clone()
    else
        assert(bigint.compare(big2, bigint.new(0), "!="), "error: divide by zero")
        assert(big1.sign == "+", "error: big1 is not positive")
        assert(big2.sign == "+", "error: big2 is not positive")

        local result = bigint.new()

        local dividend = bigint.new() -- Dividend of a single operation

        local neg_zero = bigint.new(0)
        neg_zero.sign = "-"

        for i = 1, #big1.digits do
            -- Fixes a negative zero bug
            if (#dividend.digits ~= 0) and (bigint.compare(dividend, neg_zero, "==")) then
                dividend = bigint.new()
            end
            
            table.insert(dividend.digits, big1.digits[i])
            
            local factor = bigint.new(0)
            while bigint.compare(dividend, big2, ">=") do
                dividend = bigint.subtract(dividend, big2)
                factor = bigint.add(factor, bigint.new(1))
            end

            for i = 0, #factor.digits - 1 do
                result.digits[#result.digits + 1 - i] = factor.digits[i + 1]
            end
        end

        return bigint.strip(result), dividend
    end
end

-- FRONTEND: Divide two bigs (decimals not supported), returning big result and
-- big remainder, accounting for signs
function bigint.divide(big1, big2)
    local result, remainder = bigint.divide_raw(bigint.abs(big1),
                                                bigint.abs(big2))
    if (big1.sign == big2.sign) then
        result.sign = "+"
    else
        result.sign = "-"
    end

    return result, remainder
end

-- FRONTEND: Return only the remainder from bigint.divide
function bigint.modulus(big1, big2)
    local result, remainder = bigint.divide(big1, big2)

    -- Remainder will always have the same sign as the dividend per C standard
    -- https://en.wikipedia.org/wiki/Modulo_operation#Remainder_calculation_for_the_modulo_operation
    remainder.sign = big1.sign
    return remainder
end

return bigint
