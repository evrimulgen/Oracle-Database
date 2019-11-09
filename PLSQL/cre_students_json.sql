create table students(json_data CLOB constraint chk_json Check (json_data IS JSON));
/
insert into  students
values (
'{
    "class": {
        "students": [{
                "name": "Joe",
                "rollnum": 11,
                "homephone": 3211113312,
                "joined_on": "2016-03-01",
                "subjects": [{
                    "subject_id": 21,
                    "marks": 53
                }, {
                    "subject_id": 23,
                    "marks": 43
                }, {
                    "subject_id": 24,
                    "marks": 35
                }, {
                    "subject_id": 25,
                    "marks": 90
                }, {
                    "subject_id": 26,
                    "marks": 87
                }]
            }, {
                "name": "Toe",
                "rollnum": 12,
                "homephone": 1231231122,
                "joined_on": "2016-03-01",
                "subjects": [{
                    "subject_id": 21,
                    "marks": 66
                }, {
                    "subject_id": 23,
                    "marks": 77
                }, {
                    "subject_id": 24,
                    "marks": 88
                }, {
                    "subject_id": 25,
                    "marks": 90
                }, {
                    "subject_id": 26,
                    "marks": 98
                }]
            },
            {
                "name": "Roe",
                "rollnum": 15,
                "homephone": 3332221111,
                "joined_on": "2016-03-01",
                "subjects": [{
                    "subject_id": 21,
                    "marks": 56
                }, {
                    "subject_id": 23,
                    "marks": 57
                }, {
                    "subject_id": 24,
                    "marks": 87
                }, {
                    "subject_id": 25,
                    "marks": 66
                }, {
                    "subject_id": 26,
                    "marks": 76
                }]
            }
        ]
    }
}');
/