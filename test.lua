--@enable = true
--@module = true
local argparse = require('argparse')
local eventful = require('plugins.eventful')
local utils = require('utils')
local repeatutil = require('repeat-util')
local GLOBAL_KEY = 'test'
local EVENT_FREQ = 5
local REPEAT_DAYS = 7
local UNIT_ID = 'unit_id'
local ADAMANTINE_INDEX = dfhack.matinfo.find('ADAMANTINE').index
local WATCHED_ITEMS =
utils.invert {
  df.item_type.TOOL,
  df.item_type.WEAPON,
  df.item_type.ARMOR,
  df.item_type.SHOES,
  df.item_type.SHIELD,
  df.item_type.HELM,
  df.item_type.GLOVES,
  df.item_type.AMMO,
  df.item_type.PANTS,
  df.item_type.TRAPCOMP,
--  df.item_type.COIN -- not realy something that's melted usualy, no need to check it
}
local HAS_MATERIAL_SIZE =
utils.invert {
  df.item_type.GLOVES,
  df.item_type.HELM,
  df.item_type.SHIELD,
  df.item_type.SHOES,
  df.item_type.ARMOR,
  df.item_type.WEAPON,
  df.item_type.PANTS,
  df.item_type.INSTRUMENT,
  df.item_type.TRAPCOMP,
  df.item_type.TOOL
}
local MELT_JOB_ID = df.job_type.MeltMetalObject
local created_metal = {}
local string_or_int_to_boolean = {
  ['true'] = true,
  ['false'] = false,
  ['1'] = true,
  ['0'] = false,
  ['Y'] = true,
  ['N'] = false,
  [1] = true,
  [0] = false
}

local function getBoolean(value)
  return string_or_int_to_boolean[value]
end
---------------------------------------------------------------------------------------------------
local function getDefaultState()
  return {
    enabled = true,
    verbose = false,
    share_melt_remainder_on_fort_level = true,
    melting_registry = {},
    melting_remainder = {}
  }
end --getDefaultState
---------------------------------------------------------------------------------------------------
state = state or getDefaultState()
---------------------------------------------------------------------------------------------------
local function numericTableKeysToString(source)
  local temp_table = {}
  if source ~= nil then
    for k, v in pairs(source) do
      temp_table[tostring(k)] = v
    end
  end
  return temp_table
end
---------------------------------------------------------------------------------------------------
local function stringTableKeysToNumber(source)
  local temp_table = {}
  if not source then
    for k, v in pairs(source) do
      temp_table[tonumber(k)] = v
    end
  end
  return temp_table
end
---------------------------------------------------------------------------------------------------
local function printLocal(text)
  print(GLOBAL_KEY .. ': ' .. text)
end
---------------------------------------------------------------------------------------------------
local function printDetails(text)
  if state.verbose then
    printLocal(text)
  end
end
---------------------------------------------------------------------------------------------------
function dumpToString(o)
  if type(o) == 'table' then
    local s = '{ '
    for k, v in pairs(o) do
      if type(k) ~= 'number' then
        k = '\'' .. k .. '\''
      end
      s = s .. '[' .. k .. '] = ' .. dumpToString(v) .. ','
    end
    return s .. '} '
  else
    return tostring(o)
  end
end
---------------------------------------------------------------------------------------------------
local function persistState()
  printDetails(('start persistState'))
  --remove entries for non existing jobs
  for job_id, _ in pairs(state.melting_registry) do
    local job_found = false

    for _, job in utils.listpairs(df.global.world.jobs.list) do
      if job.id == job_id then
        job_found = true
      end
    end

    if not job_found then
      state.melting_registry[job_id] = nil
    end
  end
  for i, j in pairs(state.melting_remainder) do
    if j == 0 then
      state.melting_remainder[i] = nil
    end
  end
  ---------------------------------------------------------------------------------------------------
  printDetails(('state:' .. dumpToString(state)))
  local state_to_persist = utils.clone(state)
  state_to_persist.melting_registry = numericTableKeysToString(state.melting_registry)
  state_to_persist.melting_remainder = numericTableKeysToString(state.melting_remainder)
  dfhack.persistent.saveSiteData(GLOBAL_KEY, state_to_persist)
  printDetails(('end persistState'))
end --persistState
---------------------------------------------------------------------------------------------------
local function loadState()
  printDetails(('start loadState'))
  -- load persistent data
  local persisted_data = dfhack.persistent.getSiteData(GLOBAL_KEY, state)

  printDetails(('state:' .. dumpToString(state)))
  printDetails(('persisted_data:' .. dumpToString(persisted_data)))

  if persisted_data ~= nil then
    utils.assign(state, persisted_data)
    state.melting_registry = stringTableKeysToNumber(state.melting_registry)
    state.melting_remainder = stringTableKeysToNumber(state.melting_remainder)
  end

  printDetails(('state:' .. dumpToString(state)))
  printDetails(('end loadState'))
end --loadState
---------------------------------------------------------------------------------------------------
local function updateEventListener()
  printDetails(('start updateEventListener'))
  if state.enabled then
    eventful.enableEvent(eventful.eventType.JOB_COMPLETED, EVENT_FREQ)
    eventful.enableEvent(eventful.eventType.JOB_STARTED, EVENT_FREQ)
    eventful.onJobCompleted[GLOBAL_KEY] = onJobCompleted
    eventful.onJobStarted[GLOBAL_KEY] = onJobStarted
    repeatutil.scheduleUnlessAlreadyScheduled(GLOBAL_KEY, REPEAT_DAYS, 'days', eventLoop)
    eventful.enableEvent(eventful.eventType.JOB_INITIATED, frequency)
    eventful.onJobInitiated[GLOBAL_KEY] = onJobInitiated
    printLocal(('Subscribing in eventful for %s with frequency %s'):format('JOB_STARTED,JOB_COMPLETED', EVENT_FREQ))
    printLocal(
      ('Starting repeatutil job every %s days to remove missing melting jobs from state and save it'):format(
        REPEAT_DAYS
      )
    )
  else
    eventful.onJobCompleted[GLOBAL_KEY] = nil
    eventful.onJobStarted[GLOBAL_KEY] = nil
    eventful.onJobInitiated[GLOBAL_KEY] = nil
    repeatutil.cancel(GLOBAL_KEY)
    printLocal(('Unregistering from eventful for %s, cancel repeatutil job'):format('JOB_STARTED,JOB_COMPLETED'))
  end
  printDetails(('end updateEventListener'))
end --updateEventListener
---------------------------------------------------------------------------------------------------
function eventLoop()
  -- save state anc remove canceled jobs
  persistState()
  repeatutil.scheduleUnlessAlreadyScheduled(GLOBAL_KEY, REPEAT_DAYS, 'days', eventLoop)
end
---------------------------------------------------------------------------------------------------
local function doEnable()
  printDetails(('start doEnable'))
  state.enabled = true
  updateEventListener()
  printDetails(('end doEnable'))
end
---------------------------------------------------------------------------------------------------
local function doDisable()
  printDetails(('start doDisable'))
  state.enabled = false
  updateEventListener()
  printDetails(('end doDisable'))
end
---------------------------------------------------------------------------------------------------
local function printStatus()
  printLocal(('Status %s.'):format(state.enabled and 'enabled' or 'disabled'))
  printLocal('failed to stop creation of: ' .. dumpToString(created_metal))
  printDetails(('verbose mode is %s'):format(state.verbose and 'enabled' or 'disabled'))
end -- printStatus
---------------------------------------------------------------------------------------------------
if dfhack_flags.module then
  return
end
---------------------------------------------------------------------------------------------------
dfhack.onStateChange[GLOBAL_KEY] = function(sc)
  if sc == SC_MAP_UNLOADED then
    doDisable()
    return
  end

  if sc == SC_PAUSED and df.global.gamemode == df.game_mode.DWARF then
    persistState()
  end

  if sc ~= SC_MAP_LOADED or df.global.gamemode ~= df.game_mode.DWARF then
    return
  end

  loadState()
  printStatus()
  updateEventListener()
end
---------------------------------------------------------------------------------------------------
if df.global.gamemode ~= df.game_mode.DWARF or not dfhack.isMapLoaded() then
  dfhack.printerr(GLOBAL_KEY .. ' needs a loaded fortress to work')
  return
end
---------------------------------------------------------------------------------------------------
function getMaterialSize(item)
  if HAS_MATERIAL_SIZE[item:getType()] then
    printDetails('item.subtype.material_size= ' .. item.subtype.material_size)
    return item.subtype.material_size
  else
    printDetails('item:getMaterialSizeForMelting(): ' .. item:getMaterialSizeForMelting())
    return item:getMaterialSizeForMelting()
  end
end
---------------------------------------------------------------------------------------------------
local function getSmelterMeltRemainder(index, offset_to_fix, smelter_melt_remainder)
  printDetails('getSmelterMeltRemainder start')
  printDetails('index: ' .. index)
  printDetails('offset_to_fix: ' .. offset_to_fix)
  printDetails('smelter_melt_remainder: ' .. smelter_melt_remainder)
  local to_smelter
  if not state.melting_remainder[index] then
    state.melting_remainder[index] = 0
  end
  printDetails('state.melting_remainder[index]:' .. state.melting_remainder[index])

  local melted_metal = offset_to_fix + smelter_melt_remainder + state.melting_remainder[index]
  local smelter_remainder_treshold = 1
  if state.share_melt_remainder_on_fort_level then
    -- create one shared melt remainder for whole fort
    smelter_remainder_treshold = 10
  end
  if melted_metal >= smelter_remainder_treshold then
    to_smelter = math.floor(melted_metal)
    state.melting_remainder[index] = melted_metal - math.floor(melted_metal)
  elseif melted_metal < 0 then
    if not created_metal[index] then
      created_metal[index] = 0
    end
    created_metal[index] = created_metal[index] + melted_metal
    printLocal('missed something, extra metal %s created: %s deci bars')
    -- one of: two items with 1,5 bar return melted one after another in separate jobs
    -- and/or multiple melt jobs executed between event triggers before melt remainder could be corrected
    -- and/or workorder job got cancelled before next onJobStarted in series or final onJobCompleted event was triggered
    to_smelter = 0
    state.melting_remainder[index] = 0
  else
    to_smelter = 0
    state.melting_remainder[index] = melted_metal
  end

  printDetails('to_smelter:' .. to_smelter)
  printDetails('state.melting_remainder[index]:' .. state.melting_remainder[index])
  printDetails('getSmelterMeltRemainder end')
  return to_smelter
end
---------------------------------------------------------------------------------------------------
function handleJob(job)
  if state.verbose then
    dfhack.job.printJobDetails(job)
  end

  if not state.melting_registry[job.id] then
    if state.share_melt_remainder_on_fort_level then
      -- gather melting reminder from smelter asap to prevent metal being created
      for _, r in pairs(job.general_refs) do
        if r._type == df.general_ref_building_holderst then
          local smelter = df.building.find(r.building_id)
          if (smelter.type == df.furnace_type.Smelter or smelter.type == df.furnace_type.MagmaSmelter) then
            for index, j in pairs(smelter.melt_remainder) do
              if j > 0 then
                printDetails('smelter.melt_remainder[index]: ' .. index .. ': ' .. j)
                local to_smelter = getSmelterMeltRemainder(index, 0, j)
                smelter.melt_remainder[index] = to_smelter
              end
            end
          end
        end
      end
    end
    return --nothing else to do with this job at this time
  end

  printDetails('state.melting_registry for id:' .. dumpToString(state.melting_registry[job.id]))
  for _, r in pairs(job.general_refs) do
    if r._type == df.general_ref_building_holderst then
      local smelter = df.building.find(r.building_id)
      if (smelter.type == df.furnace_type.Smelter or smelter.type == df.furnace_type.MagmaSmelter) then
        for index, offset_to_fix in pairs(state.melting_registry[job.id]) do
          if index ~= UNIT_ID then
            printDetails('handling index:' .. index)
            printDetails('smelter.melt_remainder[index]: ' .. smelter.melt_remainder[index])
            local to_smelter = getSmelterMeltRemainder(index, offset_to_fix, smelter.melt_remainder[index])

            if to_smelter >= 10 then
              local bars_to_create = math.floor(to_smelter / 10)
              printDetails('bars_to_create : ' .. bars_to_create)
              to_smelter = math.fmod(to_smelter, 10)
              printDetails('to_smelter : ' .. to_smelter)
              printDetails('unit id : ' .. state.melting_registry[job.id][UNIT_ID])
              local creator = df.unit.find(state.melting_registry[job.id][UNIT_ID])
              for i = bars_to_create, 1, -1 do
                printDetails(i)
                local created_items =
                dfhack.items.createItem(
                  creator,
                  df.item_type.BAR,
                  -1,
                  dfhack.matinfo.find('INORGANIC').type,
                  index
                )
                dfhack.items.moveToBuilding(created_items[1], smelter)
              end
            end
            smelter.melt_remainder[index] = to_smelter
            printDetails('smelter.melt_remainder[index]: ' .. smelter.melt_remainder[index])
          end
        end

        --printDetails('after fix smelter.melt_remainder.index: ' .. smelter.melt_remainder.index)
      end
    end
  end
  state.melting_registry[job.id] = nil
  printDetails('state.melting_registry total: ' .. dumpToString(state.melting_registry))
  printDetails('state.melting_remainder total: ' .. dumpToString(state.melting_remainder))
end -- handleJob
---------------------------------------------------------------------------------------------------
function onJobInitiated(job)
  if job.job_type == MELT_JOB_ID then
    printDetails('-----------onJobInitiated-----------')
    handleJob(job)
  end
end
---------------------------------------------------------------------------------------------------
function onJobCompleted(job)
  if job.job_type == MELT_JOB_ID then
    printDetails('-----------onJobCompleted-----------')
    handleJob(job)
  end
end
---------------------------------------------------------------------------------------------------
function getForgeStackSize(item_type)
  printDetails(item_type)
  printDetails(df.item_type[item_type])
  if item_type == df.item_type.GLOVES or item_type == df.item_type.SHOES then
    return 2
  end
  if item_type == df.item_type.AMMO then
    return 25
  end
  if item_type == df.item_type.COIN then
    return 500
  end
  return 1
end
---------------------------------------------------------------------------------------------------
local function getActualForgingCostInDeciBars(material_size, stack_size, forge_stack_size, mat_index)
  if ADAMANTINE_INDEX ~= mat_index then
    return math.max(math.floor(material_size / 3), 1) * 10 * stack_size / forge_stack_size
  else
    return material_size * 10 * stack_size / forge_stack_size
  end
end
---------------------------------------------------------------------------------------------------
local function addToMeltingRegistry(job_id, unit_id, mat_index, offset_to_fix)
  printDetails('addToMeltingRegistry start')
  printDetails('job_id: ' .. job_id)
  if not state.melting_registry[job_id] then
    printDetails('addToMeltingRegistry job_id init')
    state.melting_registry[job_id] = {}
  end

  if mat_index and not state.melting_registry[job_id][mat_index] then
    printDetails('addToMeltingRegistry mat_index init')
    state.melting_registry[job_id][mat_index] = 0
  end

  if unit_id then
    state.melting_registry[job_id][UNIT_ID] = unit_id
  end

  if offset_to_fix then
    printDetails('addToMeltingRegistry offset_to_fix init')
    state.melting_registry[job_id][mat_index] = state.melting_registry[job_id][mat_index] + offset_to_fix
    printDetails('state.melting_remainder[index]: ' .. dumpToString(state.melting_remainder[mat_index]))
    printDetails('state.melting_registry[job_id]: ' .. dumpToString(state.melting_registry[job_id]))
  end
  printDetails('addToMeltingRegistry end')
end --addToMeltingRegistry
---------------------------------------------------------------------------------------------------
local function validateItemType(item_type)
  if WATCHED_ITEMS[item_type] then
    return true
  end
  return false
end
---------------------------------------------------------------------------------------------------
function onJobStarted(job)
  if job.job_type == MELT_JOB_ID then
    printDetails('-----------onJobStarted-----------')
    printDetails('job.id: ' .. dumpToString(job.id))
    handleJob(job)
    for _, r in pairs(job.general_refs) do
      if r._type == df.general_ref_unit_workerst then
        addToMeltingRegistry(job.id, r.unit_id, nil, nil)
      end
    end

    for _, i in pairs(job.items) do
      local item = i.item
      if validateItemType(item:getType()) then
        printDetails('getType(): ' .. df.item_type[item:getType()])
        local material_size = getMaterialSize(item)
        local forge_stack_size = getForgeStackSize(item:getType())
        local mat_index = item:getMaterialIndex()

        local actual_forging_cost_in_db =
        getActualForgingCostInDeciBars(material_size, item.stack_size, forge_stack_size, mat_index)
        local valilla_melt_return_in_db =
        math.max(math.floor(item:getMaterialSizeForMelting() * 3 * item.stack_size / forge_stack_size), 1)
        local offset_to_fix = actual_forging_cost_in_db - valilla_melt_return_in_db
        addToMeltingRegistry(job.id, nil, mat_index, offset_to_fix)
        printDetails('state.melting_registry for id:' .. dumpToString(state.melting_registry[job.id]))
      end
    end
  end
end -- onJobStarted
---------------------------------------------------------------------------------------------------
local args, opts = {...}, {}

if dfhack_flags and dfhack_flags.enable then
  args = {dfhack_flags.enable_state and 'ENABLE' or 'DISABLE'}
end

local positionals =
argparse.processArgsGetopt(
  args,
  {
    {
      'h',
      'help',
      handler = function()
        opts.help = true
      end
    }
  }
)

local command = positionals[1]

if command ~= nil then
  command = string.upper(command)
end

if command == 'HELP' or opts.help then
  print(dfhack.script_help())
elseif command == 'ENABLE' or command == 'E' then
  doEnable()
elseif command == 'DISABLE' or command == 'D' then
  doDisable()
elseif command == 'VERBOSE' or command == 'V' then
  state.verbose = getBoolean(positionals[2])
elseif command == 'SHARE' or command == 'S' then
  state.share_melt_remainder_on_fort_level = getBoolean(positionals[2])
elseif command == 'CLEAR' then
  printDetails('CLEAR')
  state = getDefaultState()
elseif command == 'TEST' then
  --  for i=0, 100, 1 do
  --    print(df.item_type[i])
  --print(df.item_type.AMMO)
  --  end
  for t, _ in pairs(WATCHED_ITEMS) do
    print(t)
    print(df.item_type[t])
    print(validateItemType(t))
  end

elseif positionals[1] ~= nil then
  qerror(('Command \'% s\' is not recognized'):format(positionals[1]))
end

printStatus()
persistState()
