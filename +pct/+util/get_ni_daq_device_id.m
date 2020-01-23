function device_id = get_ni_daq_device_id()

devices = daq.getDevices();
vendors = { devices.Vendor };

for i = 1:numel(vendors)
  if ( strcmp(vendors{i}.ID, 'ni') )
    device_id = devices(i).ID;
    return
  end
end

error( 'Could not locate a DAQ device with ID ''ni''.' );

end