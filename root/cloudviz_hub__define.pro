;+
; CLASS_NAME:
;  cloudviz_hub
;
; PURPOSE:
;  The hub object for visualizing hierarchical cloud data. This object
;  manages message passing between individual visualization modules
;  (which themselves are cloudviz_client objects). Clients use the hub
;  methods to communicate information about which substructures are
;  being selected.
;
; CATEGORY:
;  Visualization, cloudviz
;
; SUPERCLASSES:
;  IDL_CONTAINER
;
; SUBCLASSES:
;  none.
;
; CREATION:
;  see cloudviz_hub::init
;
; DESCRIPTION:
;  The cloudviz library provides routines to visualize and interact
;  with hierarchical catalogs of cloud structure (created, e.g., by
;  dendrograms). These tools are organized in a "hub-client" system:
;  the hub stores the majority of data about the cloud structure, and
;  communicates this information to individual visualization modules.
;
;  The general structure of a cloudviz program is:
;    -  Create a new hub object, which holds the main cloud data
;    -  Create one or more client objects, and add them to 
;       the hub via the hub's addClient method
;    -  Add a cloudviz_listener object via the setListener
;       method. This object will process keyboard presses and other
;       generic events relayed by clients.
;    -  User interacts with the client modules. At their discretion,
;       clients relay widget events to the hub via the receiveEvent method
;    -  Client objects detect user interaction, and optionally relay
;       this information to the hub via the hub's receiveEvent method. 
;    -  Clients may detect that the user is highlighting
;       substructures within the cloud. They communicate this
;       to the hub via the hub's setCurrentStructure method
;    -  If necessary, the hub relays this information to the
;       other clients, updating their displays
;
;  Dendroviz.pro provides a standard configuration of the cloudviz modules.
;
; METHODS:
;  The following methods are public:
;
;  receiveEvent: Client objects relay gui events to the hub via this
;                method
;  getLeader: Return the viz client designated as the "leader"
;  getListener: Return the event listener object
;  addListener: Update the object which processes widget events
;  addClient: Add a new visualization module to the hub
;  setLeader: Update which client is the "leader"
;  setCurrentStructure: Used by clients to inform the hub of the newly
;                       highlighted substructure 
;  getColors: Return an array of (RGBA) colors for each substructure
;  setColor: Re-define one of the substructure colors
;  setCurrentID: Update which substructre id is currently edited
;  getCurrentID: Return the current id
;  getCurrentStructure: Return the substructure  for the current mask
;  getData: Return the cloud pixel data
;  forceUpdate: Manually refresh all of the client displays
;  init: Create a new hub
;
; MODIFICATION HISTORY:
;  Feb 2011: Written by Chris Beaumont, adapted from the older
;  dendrogui code.
;-

;+
; PURPOSE:
;  Used by clients to relay gui events
;
; INPUTS:
;  event: A standard widget event structure
; 
; BEHAVIOR:
;  The event is passed to the hub's event listener for further
;  processing.
;-
pro cloudviz_hub::receiveEvent, event, _extra = extra
  if obj_valid(self.listener) then $
     self.listener->event, event
end

;+
; PURPOSE:
;  Return the current leader client. When the leader client is
;  destroyed, the hub and all other clients are also shutdown.
;  
;  By default, the first client added to the hub is the leader. This
;  can be overridden vai the setLeader method.
;
; INPUTS:
;  none
;
; OUTPUTS:
;  The leader client
;-
function cloudviz_hub::getLeader
  return, self.leader
end

;+
; PURPOSE:
;  Return the event listener object for the hub. The event listener processes
;  any widget events passed to the hub via the receiveEvent
;  method. Listener objects can be used to process visualization-wide
;  events like keyboard shortcuts
;
; INPUTS:
;  none
;
; OUTPUTS:
;  The event listener object
;-
function cloudviz_hub::getListener
  return, self.listener
end


;+
; PURPOSE:
;  Add a new event listener to the hub. See getListener method for details.
;
; INPUTS:
;  listener: An instance of a cloudviz_listener object.
;-
pro cloudviz_hub::addListener, listener
  if ~obj_valid(listener) || ~obj_isa(listener, 'cloudviz_listener') then $
     message, 'listener is not a valid cloud_listener object'
  self.listener = listener
end


;+
; PURPOSE:
;  Add a new visualization module
;
; INPUTS:
;  client: A cloudviz_client object
;-
pro cloudviz_hub::addClient, client
  self->add, client
  self->reflow, client
  self->forceUpdate, client
end


;+
; PURPOSE:
;  Define a new leader client. When a leader client is destroyed, the
;  hub and all oher clients are also destroyed.
;
; INPUTS:
;  leader: The new leader
;-
pro cloudviz_hub::setLeader, leader
  if ~obj_valid(leader) || ~obj_isa(leader, 'cloudviz_client') then $
     message, 'leader must be a cloudviz_client object'
  self.leader = leader
end


;+
; PURPOSE:
;  Overrides IDL_CONTAINER's add method. You should not use
;  this method directly.
;  
; INPUTS:
;  client: The new client to add.
;
; KEYWORD PARAMETERS:
;  leader: Set to indicate this client is the leader
;-
pro cloudviz_hub::add, client, leader = leader
  if ~obj_valid(client) || ~obj_isa(client, 'cloudviz_client') then $
     message, 'hubs can only hold cloudviz_client objects'
  cs = self->get(/all, count = ct)
  if ct eq 0 || keyword_set(leader) then self.leader = client
  self->IDL_CONTAINER::add, client
  self->reflow, client
  client->run
end


;+
; PURPOSE:
;  Rearrange the client windows to (hopefully) prevent overlap. 
;
; INPUTS:
;  single: An optional reference to one of the client objects. If
;  provided, only "single" will be repositioned. Otherwise, all
;  windows will be repositioned.
;
;-
pro cloudviz_hub::reflow, single
  cs = self->get(/all, count = ct)
  dx = 400
  dy = 100
  sz = get_screen_size()
  x = 0
  y = 0
  for i = 0, ct - 1, 1 do begin
     if ~obj_valid(cs[i]) then continue
     base = cs[i]->getWidgetBase()
     valid = widget_info(base, /valid)
     if valid && (~obj_valid(single) or single eq cs[i]) then $
        widget_control, base, xoffset = x, yoffset = y
     x += dx
     if (x + dx ge sz[0]) then begin
        x = 0
        y += dy
        y = y < (sz[1] - dy)
     endif
  endfor
end


;+
; PURPOSE:
;  Used by clients to communicate that a new substructure has been
;  highlighted. The hub will broadcast this change to all clients.
;
; INPUTS:
;  structure: A scalar or vector describing the newly highlighted
;  substructure. This is a list of structure ids (corresponding to IDs
;  in the cloud structure pointer provided to the hub::init method)
;
; KEYWORD PARAMETERS:
;  Force: Set to force all an update of all client windows. If not
;  set, clients have the option of ignoring new substructure
;  assignments to avoid expensive calculations
;-
pro cloudviz_hub::setCurrentStructure, structure, force = force
  self->setHourglass

  ;- store new structure
  if ptr_valid(self.structure_ids[self.currentID]) then begin
     old = *(self.structure_ids[self.currentID])
     if array_equal(structure, old) then return
     *(self.structure_ids[self.currentID]) = structure
  endif else $
     self.structure_ids[self.currentID] = ptr_new(structure)

  ;- broadcast update to clients
  clients = self->IDL_CONTAINER::get(/all, count = ct)
  for i = 0, ct - 1, 1 do begin
     if ~obj_valid(clients[i]) then continue
     clients[i]->notifyStructure, self.currentID, structure, force = force
  endfor

end


;+
; PURPOSE:
;  Destroy the hub and all clients
;-
pro cloudviz_hub::cleanup
  self->IDL_CONTAINER::cleanup
  ptr_free, [self.structure_ids]
  obj_destroy, [self.listener, self.leader]
  !except = 0
end


;+
; PURPOSE:
;  Get the RGBA color of one of the substructures
;
; INPUTS:
;  Index: a value (0-7) indicating which color to select
;
; OUTPUTS:
;  An (R,G,B,A) set of byte values in the range 0-255
;-
function cloudviz_hub::getColors, index
  return, self.colors[*,index]
end


;+
; PURPOSE:
;  Update one of the substructure colors
; 
; INPUTS:
;  index: Which substructure to update
;  color: A new (RGBA) color. RGB in the range 0-255. A in the range
;  0-1.
;-
pro cloudviz_hub::setColor, index, color
  self->setHourglass
  self.colors[*,index] = byte(color * [1,1,1,256] < 255)
  clients = self->get(/all, count = ct)
  for i = 0, ct - 1, 1 do begin
     if ~obj_valid(clients[i]) then continue
     clients[i]->notifyColor, index, color
  endfor
end


;+
; PURPOSE:
;  Update which substructure is currently being edited
;
; INPUTS:
;  id: Which structure to edit. 0-7.
;-
pro cloudviz_hub::setCurrentID, id
  self.currentID = id
  clients = self->get(/all, count = ct)
  for i = 0, ct - 1, 1 do begin
     if ~obj_valid(clients[i]) then continue
     clients[i]->notifyCurrent, id
  endfor
end


;+
; PURPOSE:
;  Get the currently-editable substructure
;
; OUTPUTS:
;  A number (0-7) indicating which structure is being edited
;-
function cloudviz_hub::getCurrentID
  return, self.currentID
end


;+
; PURPOSE:
;  Return one of the substructures
;
; INPUTS:
;  Index: Which substructure (0-7) to return
;
; OUTPUTS:
;  A list of the structure ids (as listed in the structure pointer
;  provided to hub::init) that are highlighted by substructure INDEX
;-
function cloudviz_hub::getStructure, index
  return, ptr_valid(self.structure_ids[index]) ? *self.structure_ids[index] : -1
end


;+
; PURPOSE:
;  Returns the structure corresponding to the currently-editable
;  substructure. Equivalent to hub->getStructure( hub->getCurrentID())
;
; RETURNS:
;  hub->getStructure(hub->getCurrentID())
;-
function cloudviz_hub::getCurrentStructure
  return, self->getStructure(self.currentID)
end


;+
; PURPOSE:
;  Return the pixel data provided to the hub::init method
;
; RETURNS:
;  The pixel data associated with the cloud
;-
function cloudviz_hub::getData
  return, self.data
end


;+
; PURPOSE:
;  Set the hourglass cursor for all clients, to communicate that an
;  expensive calculation is coming. 
;-
pro cloudviz_hub::setHourglass
  cs = self->get(/all, count = ct)
  for i = 0, ct - 1, 1 do begin
     if ~obj_valid(cs[i]) then continue
     base = cs[i]->getWidgetBase()
     valid = widget_info(base, /valid)
     if valid then widget_control, base, /hourglass
  endfor
end


;+
; PURPOSE:
;  Force all clients to update their displays
;-
pro cloudviz_hub::forceUpdate, single
  self->setHourglass

  clients = self->IDL_CONTAINER::get(/all, count = ct)
  for i = 0, ct - 1, 1 do begin
     if ~obj_valid(clients[i]) then continue
     if obj_valid(single) && single ne clients[i] then continue
     for j = 0, 7, 1 do begin
        clients[i]->notifyStructure, j, self->getStructure(j), /force
     endfor
  endfor
end


;+
; PURPOSE:
;  Create a new cloudviz hub object
;
; INPUTS:
;  ptr: A pointer to a structure describing the cloud hierarchy. This
;  structure must have the following tags:
;    value: An array (cube or image) of cloud intensity values
;    cluster_label: An array (same size/shape as value) indicating the
;                   structure ID for each pixel
;    clusters: A [2, nleaf/2-1] array describing a dendrogram structure
;              hierarchy. The 2 entries in clusters[*, i] give the ID's
;              of the substructures whose merger defines structure (i
;              + nleaf). The leaves are structures without any
;              substructures, and thus aren't listed in this array
;    cluster_label_h: The histogram of cluster_label. The first bin
;                     is assumed to be at x=0
;    cluster_label-ri: The reverse indices array of cluster_label_h
;                      (see histogram documentation)
;
;
; KEYWORD PARAMETERS:
;  Colors: A [4,8] byte array giving the default (RGBA) colors for
;          each of the 8 substructure masks.
;
; OUTPUTS:
;  1 for success, 0 otherwise
;-
function cloudviz_hub::init, ptr, colors = colors

  if size(ptr, /type) ne 10 || ~ptr_valid(ptr) || $
     size(*ptr, /type) ne 8 || ~contains_tag(*ptr, 'CLUSTERS') || $
     ~contains_tag(*ptr, 'CLUSTER_LABEL_H') || $
     ~contains_tag(*ptr, 'CLUSTER_LABEL_RI')|| $
     ~contains_tag(*ptr, 'CLUSTER_LABEL') || $
     ~contains_tag(*ptr, 'VALUE') then $
        message, 'Pointer does not point to a structure with the proper tags'
     
  !except = -1
  self.data = ptr

  if keyword_set(colors) then begin
     sz = size(colors)
     if sz[0] ne 2 || sz[1] ne 4 || sz[2] ne 8 then $
        message, 'Colors keyword must be a [4,8] byte array'
     self.colors = colors
  endif else begin
     colors = byte(transpose(fsc_color( $
              ['red', 'teal', 'orange', 'purple', 'yellow', $
               'brown', 'royalblue', 'green'], /triple)))
     assert, n_elements(colors[0,*]) eq 8
     self.colors[0:2,*] = colors
     self.colors[3,*] = 128B
  endelse

  self.isListening = 1

  return, 1
end


pro cloudviz_hub__define
  data = {cloudviz_hub, $
          inherits IDL_CONTAINER, $
          listener:obj_new(), $ ;- cloudviz_listener object to process events
          data: ptr_new(), $    ;- cloud structure pointer
          colors: bytarr(4, 8), $     ;- colors for each substructure mask
          structure_ids: ptrarr(8), $ ;- substructure ids for each mask
          currentID: 0, $             ;- currently-selected mask
          leader:obj_new(), $         ;- leader client
          isListening: 0B $           ;- are we processing events?
         }
end
