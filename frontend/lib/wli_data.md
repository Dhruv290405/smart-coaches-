isme wli ka data jo future me aayega apis ke thorugh uska formate hai toh hame abhi iske behalf par change kr dena
hai current wale ko toh - 

abhi ek card hai wo 2 card banege coaches ke show hone ke liye kyuki ek coach me 2 sensor hai 

- underslug tank 
- overhead tank 

fontend update krna hai + break binding wale me se jo chart hai wahi chart wli me bhi laga dena 


data -


Underslung Tank  :- Only one sensor : -
They are mounted below the coach (underframe)  . Usually only 1 sensor (center position) . Water distribution is more uniform → one reading is enough  
Only one sensor : -
PP and NPP :- Not Necessary To Shown In app

Data :-
{
"source": {
"companyName": "VASP Rails Tech",
"systemType": "WLI",
"deviceId": "F24ENWR45"
},

"location": {
"coachId": "COACH_01",
"coachName": "Coach 01"
},

"messageType": "METRICS",
"timestamp": "2026-04-23T06:39:50Z",

"placement": {
"type": "UNDERSLUNG",
"sensorCount": 1,
"position": ["CENTER"]
},

"assets": [
{
"assetId": "7137b442-7b88-4faa-877a-cfbf36dd30ba",
"assetName": "Water Tank Sensor",

      "rawValue": 414,
      "levelCm": 28,
      "volumeLiters": 155.4,
      "percentFull": 100
    }
]
}





Overhead Tank :-  Only Two Sensor

·Mounted on top of the coach (roof) . Due to tilt, movement, uneven filling → 2 sensors needed
Sensors placed at:  
Front End
Rear End
PP and NPP :- Not Necessary To Shown In app

Data :-
{
"source": {
"companyName": "VASP Rails Tech",
"systemType": "WLI",
"deviceId": "F24ENWR45"
},

"location": {
"coachId": "COACH_01",
"coachName": "Coach 01"
},

"messageType": "METRICS",
"timestamp": "2026-04-23T06:39:50Z",

"placement": {
"type": "OVERHEAD",
"sensorCount": 2,
"position": ["FRONT_END", "REAR_END"]
},

"assets": [
{
"assetId": "7137b442-7b88-4faa-877a-cfbf36dd30ba",
"assetName": "Water Tank Sensor - Front",

      "rawValue": 414,
      "levelCm": 28,
      "volumeLiters": 155.4,
      "percentFull": 100
    },
    {
      "assetId": "7137b442-7b88-4faa-877a-cfbf36dd30bb",
      "assetName": "Water Tank Sensor - Rear",

      "rawValue": 410,
      "levelCm": 27,
      "volumeLiters": 150.2,
      "percentFull": 97
    }
]
}


