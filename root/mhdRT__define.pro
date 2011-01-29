function computeJ
  message, 'not implemented'
end

function computeK
  message, 'not implemented'
end

function mhdRT::init, sim, line
  if n_params() ne 3 then begin
     print, 'calling sequence'
     print, ' o = obj_new("mhdRT", mhdSimObject, lineInfoObject'
  endif
  if ~obj_valid(mhdSim) || ~obj_isa(sim, 'mhdSim') then $
     message, 'sim must be a mhdSim object'
  
  if ~obj_valid(line) || ~obj_isa(line, 'lineInfo') then $
     message, 'line must be a lineInfo object'

  self.mhdSim = sim
  self.lineInfo = line
end

pro mhdRT__define

  data = {mhdRT, $
          mhdSim: obj_new(), $
          lineInfo: obj_new(), $
         }
end
