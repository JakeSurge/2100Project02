import json

with open('itemlist.json', 'r') as f:
    file = json.load(f)

    for i in file:
        dic = dict(i)
        for key, value in dic.items():
            print (value)
        
