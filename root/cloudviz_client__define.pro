;+
; CLASS NAME:
;  cloudviz_client
;
; PURPOSE:
;  This class defines the interface for individual visualization
;  modules in the cloudviz library. Actual modules will subclass
;  cloudviz_client, and override most of these methods. Each method
;  defines a particular way of communicating with the hub, to allow
;  several visualization modules to easily communicate with each
;  other.
;
; SUPERCLASSES:
;  none
;
; SUBCLASSES:
;  dendroviz_client, dendroplot, cloudiso, cloudslice, cloudscatter
;
; METHODS:
;  sendEventToHub: Relay widget events to the hub
;  notifyCurrent: Used by hub to notify the module about which
;                 substructure mask is currently being edited
;  notifyColor: Used by hub to notify the module about how to color
;               each substructure mask.
;  notifyStructure: Used by hub to notify the module about which
;                   structure IDs should be assigned to a given
;                   structure mask.
;  run: Start up the visualization module, realizing widgets, etc
;  cleanup: Destroy the object
;  getWidgetBase: Return the root widget ID associated with this
;                 module.
;  init: Create a new client object
;-

pro cloudviz_client::sendEventToHub, event, _extra = extra
  self.hub->receiveEvent, event, _extra = extra
end

pro cloudviz_client::notifyCurrent, id
  ;- do nothing by default
end

pro cloudviz_client::notifyColor, id, color
  ;- do nothign by default
end

pro cloudviz_client::notifyStructure, id, structure, force = force
  ;- do nothing by default
end

pro cloudviz_client::run
  ;- do nothing by default
end

pro cloudviz_client::cleanup
  if self.hub->getLeader() eq self then obj_destroy, self.hub
  if widget_info(self.widget_base, /valid) then $
     widget_control, self.widget_base, /destroy
end

function cloudviz_client::getWidgetBase
  return, self.widget_base
end

function cloudviz_client::init, hub, ncolor = ncolor, _extra = extra
  if n_params() ne 1 then begin
     print, 'calling sequence'
     print, 'obj = obj_new("cloudviz_client", hub)'
     return, 0
  endif

  if n_elements(hub) ne 1 || ~obj_isa(hub, 'cloudviz_hub') $
     then message, 'hub is not a valid cloudviz hub object'

  if ~keyword_set(ncolor) then ncolor = 8
  self.ncolor = ncolor
  self.hub = hub
  return, 1
end

pro cloudviz_client__define
  data = {cloudviz_client, $
          hub:obj_new(), $
          widget_base:0L, $
          ncolor:0 $
         }
end
