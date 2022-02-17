#tailscale_inventory_plugin.py

DOCUMENTATION = r'''
    name: tailscale_inventory_plugin
    plugin_type: inventory
    short_description: Returns Ansible inventory from Tailscale
    description: Returns Ansible inventory from a Tailscale tailnet device list grouped by ACL Tags
    options:
      plugin:
        description: Name of the plugin
        requried: true
        choices: ['tailscale_inventory_plugin']
      tailnet:
        description: Name of your tailnet
        required: true
        env: TAILSCALE_TAILNET
      tailscale_api_key:
        description: API Key from your Tailscale account
        required: true
        env: TAILSCALE_API_KEY
'''

from ansible.plugins.inventory import BaseInventoryPlugin
from ansible.errors import AnsibleError, AnsibleParserError
from ansible.template import Templar
import requests
from requests.auth import HTTPBasicAuth


class InventoryModule(BaseInventoryPlugin):
  NAME = "tailscale_inventory_plugin"

  def verify_file(self, path):
    '''Return true/false if this is a
    valid file for this plugin to consume
    '''
    valid = False
    if super(InventoryModule, self).verify_file(path):
      if path.endswith(('tailscale_inventory.yaml','tailscale_inventory.yml')):
        valid = True
    return valid

  def _get_tailscale_devices(self, tailnet, api_key):
    '''Return a struct of all devices on a tailnet'''
    inventory_data = {}
    URL = 'https://api.tailscale.com/api/v2/tailnet/{}/devices'.format(tailnet)
    auth = HTTPBasicAuth(api_key, "")
    response = requests.get(url=URL, auth=auth)
    response.raise_for_status()
    jsonResponse = response.json()
    for device in jsonResponse.get('devices'):
      inventory_data['{}.beta.tailscale.net'.format(device['name'])] = device
    return inventory_data


  def _populate(self):
    '''Return the hosts and groups'''
    self.tailscale_inventory = self._get_tailscale_devices(self.tailnet, self.tailscale_api_key)
    tags = ['untagged']
    for data in self.tailscale_inventory.values():
      for tag in data.get('tags', []):
        tag_sanitized = tag.split(':')[1]
        if not tag_sanitized in tags:
          tags.append(tag_sanitized)
    for tag in tags:
        self.inventory.add_group(tag)
    for hostname,data in self.tailscale_inventory.items():
      for tag in data.get('tags', []):
        self.inventory.add_host(host=hostname, group=tag.split(':')[1])
      if len(data.get('tags', [])) < 1:
        self.inventory.add_host(host=hostname, group='untagged')
      self.inventory.set_variable(hostname, 'ansible_host', data.get('addresses')[0])
      self.inventory.set_variable(hostname, 'ansible_network_os', data.get('os', "unknown"))
    #import pdb; pdb.set_trace()

  def parse(self, inventory, loader, path, cache):
    '''Return dynamic inventory from source '''
    super(InventoryModule, self).parse(inventory, loader, path, cache)
    t = Templar(loader=loader)
    self._read_config_data(path)
    try:
      self.plugin = self.get_option('plugin')
      self.tailnet = self.get_option('tailnet')
      if t.is_template(self.get_option('tailscale_api_key')):
        self.tailscale_api_key = t.template(variable=self.get_option('tailscale_api_key'), disable_lookups=False)
      else:
        self.tailscale_api_key = self.get_option('tailscale_api_key')
    except Exception as e:
      raise AnsibleParserError(
        'All correct options required: {}'.format(e))
    self._populate()