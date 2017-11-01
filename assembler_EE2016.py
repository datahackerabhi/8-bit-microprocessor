#author:Abhishek Nair
#date:1/11/17

#an assembler for the 8-bit microprocessor made in EE2016 Lab.
#instructions must be on new lines and operands must be comma separated.

program_mem = open('code','r')
assembly_code = open('assemblycode','w')

mnemonic_list = { 'add':'0000','sub':'0001','and':'0010','or':'0011','lsh':'0100','rsh':'0101','load':'0110','store':'0111'}
register_list = { 'r0' :'0000','r1' :'0001','r2' :'0010','r3' :'0011','r4' :'0100','r5' :'0101'}

inreg1b = ""
inreg2b = ""
outregb = ""
mnemonicb = "" 

for instruction in program_mem:
  (mnemonic,in_reg1,in_reg2,out_reg) = (instruction.split(" ")[0],instruction.split(" ")[1].split(",")[0],instruction.split(" ")[1].split(",")[1],instruction.split(" ")[1].split(",")[2])
  (mnemonic,in_reg1,in_reg2,out_reg) = (mnemonic.rstrip(),in_reg1.rstrip(),in_reg2.rstrip(),out_reg.rstrip())
  
  if mnemonic in mnemonic_list.keys():
    mnemonicb = mnemonic_list[mnemonic]
  else:
    print("Invalid Mnemonic")
  if in_reg1 in register_list.keys():
    inreg1b = register_list[in_reg1]
  else:
    print("Invalid First Register")
  if in_reg2 in register_list.keys():
    inreg2b = register_list[in_reg2]
  else:
    print("Invalid Second Register")
  if out_reg in register_list.keys():
    outregb = register_list[out_reg]
  else:
    print("Invalid Output Register")
  
  instructionb = "16'b"+mnemonicb+inreg1b+inreg2b+outregb
  assembly_code.write(instructionb+"\n")
  
