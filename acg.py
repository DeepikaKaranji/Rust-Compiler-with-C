import re
import sys


lastReg = 0
flag = ""
def split_intermediate_code(f):
    fp=open(f,'r')
    intermediate_code=fp.read()
    intermediate_code=re.sub('\n+','\n',intermediate_code)
    intermediate_code=re.sub(' +',' ',intermediate_code)
    intermediate_code=intermediate_code.split('\n')
    flag=0
    for i in range(len(intermediate_code)):
        intermediate_code[i]=intermediate_code[i].strip()

    intermediate_code='\n'.join(intermediate_code)
    intermediate_code=re.sub('\n+','\n',intermediate_code)
    intermediate_code=re.sub(' +',' ',intermediate_code)
    intermediate_code=intermediate_code.split('\n')
    fp.close()
    return intermediate_code

def reg_var_map(intermediate_code):
#assign reg vals to each var
    global lastReg
    maps = {}
    labels = {}
    n = 0
    x = len(intermediate_code)
    i = 0
    while(i < x):
        tok = intermediate_code[i].strip()
        tok = tok.split()
        lhs = intermediate_code[i].split("=")[0]
        if(lhs not in maps):
            if("=" in tok):
                maps[lhs.strip()] = "R" + str(n)
                n += 1
        else:
            pass
        i += 1
    lastReg = n
    return maps


#this handles a=1 and then does load store
def handle_assignment(maps, data, rhs_unrolled, lhs):
    global lastReg
    if(not lhs.strip() in data):
        print("MOV " + maps[lhs.strip()] + ", #" + rhs_unrolled[0])
    else:
        #load instructions.
        #this R is the reg val
        temp_reg = "R" + str(lastReg)
        if(not rhs_unrolled[0].isnumeric()):
            print("MOV " + temp_reg + ", " + maps[rhs_unrolled[0]])
        else:
            print("MOV " + temp_reg + ", #" + rhs_unrolled[0])

        #since I am converting into mov store and load R0
        #existng map bw var and reg
        #temp_teg used for 3 reg stuff
        #assume infinite regs 
        #if no. of regs needed exceeds present, dump the extras into mem 
        print("LDR " + maps[lhs.strip()] + " ,=" + lhs.strip())
        print("STR " + temp_reg + " ,[" + maps[lhs.strip()] +"]")
        lastReg += 1


def mathOp_generator(maps, data, rhs_unrolled, lhs):
    global lastReg
    global flag

    if(rhs_unrolled[1] == "*"):
        if(rhs_unrolled[0].isnumeric()):
            x = "MUL " + maps[lhs.strip()] + ", " + maps[rhs_unrolled[2]] + ", #" + rhs_unrolled[0]
            print(x)

        elif(rhs_unrolled[2].isnumeric()):
            x = "MUL " + maps[lhs.strip()] + ", " + maps[rhs_unrolled[0]] + ", #" + rhs_unrolled[2]
            print(x)

        else:
            x = "MUL " + maps[lhs.strip()] + ", " + maps[rhs_unrolled[0]] + ", " + maps[rhs_unrolled[2]]
            print(x)
    

    elif(rhs_unrolled[1] == "+"):
        if(rhs_unrolled[0].isnumeric()):
            # print("EXPANDED RHSSSSSSSSSSS",rhs_unrolled[2],rhs_unrolled[0]  )
            x = "ADD " + maps[lhs.strip()] + ", " + maps[rhs_unrolled[2]] + ", #" + rhs_unrolled[0]
            print(x)

        elif(rhs_unrolled[2].isnumeric()):
            x = "ADD " + maps[lhs.strip()] + ", " + maps[rhs_unrolled[0]] + ", #" + rhs_unrolled[2]
            print(x)

        else:
            x = "ADD " + maps[lhs.strip()] + ", " + maps[rhs_unrolled[0]] + ", " + maps[rhs_unrolled[2]]
            print(x)
    

    
    elif(rhs_unrolled[1] == "-"):
        if(rhs_unrolled[0].isnumeric()):
            x = "SUB " + maps[lhs.strip()] + ", #" + rhs_unrolled[0] + ", " +  maps[rhs_unrolled[2]]
            print(x)

        elif(rhs_unrolled[2].isnumeric()):
            x = "SUB " + maps[lhs.strip()] + ", " + maps[rhs_unrolled[0]] + ", #" + rhs_unrolled[2]
            print(x)

        else:
            x = "SUB " + maps[lhs.strip()] + ", " + maps[rhs_unrolled[0]] + ", " + maps[rhs_unrolled[2]]
            print(x)

    
    else:
        #divisions
        if(rhs_unrolled[0].isnumeric()):
            temp_reg = "R" + str(lastReg)
            x = "MOV " + temp_reg + ", #" + maps[rhs_unrolled[0]]
            y = "CMP " +  temp_reg + ", " +  maps[rhs_unrolled[2]]
            print(x)
            print(y)

        elif(rhs_unrolled[2].isnumeric()):
            x = "CMP " +  maps[rhs_unrolled[0]] + ", #" + rhs_unrolled[2]
            print(x)
            
        else:
            x = "CMP " + maps[rhs_unrolled[0]] + ", " + maps[rhs_unrolled[2]]
            print(x)

        flagDict = {"<":"LT", "<=":"LE", ">":"GT", ">=":"GE","==":"EQ", "":""}
        flag = flagDict[flag]
    
    
    if(lhs.strip() in data):
        temp_reg = "R" + str(lastReg)
        print("LDR " + temp_reg + " ,=" + lhs.strip())
        print("STR "+ maps[lhs.strip()] + ",["+ temp_reg +"]")



def acg_generator(maps, data, intermediate_code):
    for i in range(len(intermediate_code)):
        tok = intermediate_code[i].strip().split()
        # print("---toktoktokt-------", tok[0])
        
        if("=" in intermediate_code[i]):
            pos = intermediate_code[i].find("=")
            lhs = intermediate_code[i][:pos]
            rhs = intermediate_code[i][pos+1:]
            rhs_unrolled = rhs.strip().split()
            if(len(rhs_unrolled) == 1):
                handle_assignment(maps, data, rhs_unrolled, lhs)
            elif(len(rhs_unrolled) == 3):
                mathOp_generator(maps, data, rhs_unrolled, lhs)
            elif("not" in rhs_unrolled):
                global flag
                flagSwitch = {'LT': 'GE', 'LE': 'GT', 'GE': 'LT', 'GT':'LE', 'EQ': 'NE', "":""}
                flag = flagSwitch[flag]
        elif "L" in tok[0] and ":" in tok[0]:
            # label
            print()
            print(intermediate_code[i])
        elif tok[0] == "ifFalse" and tok[2] == "goto":
            # branch
            print("B" + flag + " " + tok[-1])
        elif tok[0] == "goto":
            # goto
            print("B "+ tok[-1])

if __name__ == "__main__":
    intermediate_code = split_intermediate_code(sys.argv[1])
     
    maps = reg_var_map(intermediate_code)
    #identifies vars that use memory
    #check if temp (t00, t01 etc) and append 
    data = []
    keyList = list(maps.keys())
    for i in range(len(keyList)):
        x = keyList[i].strip()
        cond = (len(x) == 3) and ('t' in x)
        if(not cond):
            data.append(keyList[i])
    print("maps", maps, "data", data)
    print(".TEXT")

    # generate the code
    acg_generator(maps, data, intermediate_code)
    print(".DATA")
    for i in data:
        print(i +": .WORD") #need to check this out


#if =, put in assign statement
#maps?
#load val of var and store in var
#requires 3 sets of statements
#assign reg

