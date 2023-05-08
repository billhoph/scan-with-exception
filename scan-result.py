import json
import pandas as pd
from pandas import json_normalize
from tabulate import tabulate

with open('response.json') as user_file:
  file_contents = user_file.read()

parsed_json = json.loads(file_contents)
vul_info = parsed_json[0]['entityInfo']['vulnerabilityDistribution']
vul_info_df = json_normalize(parsed_json[0]['entityInfo']['vulnerabilityDistribution'])

print("-----Extracting information from API-----")
print(vul_info_df.to_string(index=False))

binary_info = parsed_json[0]['entityInfo']['vulnerabilities']
binary_info_df = json_normalize(parsed_json[0]['entityInfo']['vulnerabilities'])[['cvss','severity','packageName','packageVersion','cve','status','description']]
#binary_info_df = binary_info_df.loc[binary_info_info_df['cveCount'] > 0 ]
#['text', 'id', 'severity', 'cvss', 'status', 'cve', 'cause', 'description', 'title', 'vecStr', 'exploit', 'link', 'type', 'packageName', 'packageVersion', 'layerTime', 'templates', 'twistlock', 'cri', 'published', 'fixDate', 'applicableRules', 'discovered', 'binaryPkgs', 'functionLayer', 'exploits']
binary_info_df = binary_info_df.sort_values(['severity','packageName'],ascending=False)

print()
print("-----Extracting Detail Information-----")
#print(list(binary_info_df.columns.values))
#print(binary_info_df.to_string(index=False))
print(tabulate(binary_info_df, headers = 'keys', tablefmt = 'grid', maxcolwidths=[None,None,None,None,None,None,None,30] ))
binary_info_df.to_excel('scan_result.xlsx')


