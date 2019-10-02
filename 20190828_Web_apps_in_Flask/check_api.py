import urllib.request

import json



def get_pqs():


    req = urllib.request.Request('http://eldaddp.azurewebsites.net/commonsoralquestions/answeringdepartment.json?q=department%20for%20transport&_page=0&_sort=-dateTabled')
    try:
        response = urllib.request.urlopen(req)
    except urllib.error.URLError as e:
        if hasattr(e, 'reason'):
            print('We failed to reach a server.')
            print('Reason: ', e.reason)
            return None

    else:
        print('got response')
        str_response = response.read().decode('utf-8-sig')
        json_data = json.loads(str_response)

        response.close()
        pqs=json_data['result']['items']
        pqdict = {}
        for pq in pqs:
            pqdict[pq['tablingMemberPrinted'][0]['_value']] = pq['questionText']
        return pqdict

