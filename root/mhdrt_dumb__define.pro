function mhdRT_dumb::computeJ
  return, self.sim->getN()
end

function mhdRT_dumb::computeK
  return, self.sim->getN() * 0
end

pro mhdRT_dumb::init, sim
  line = obj_new('lineInfo')
  result = self->mhdRT::init(sim, line)
end

pro mhdRT_dumb__define
  data = {mhdRT_dumb, $
          inherits mhdRT $
         }
end
