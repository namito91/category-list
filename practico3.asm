.data

ccobj:     .word  0    # puntero a lista de objetos 
slist:     .word  0    # slist: puntero usado por las funciones smalloc y sfree
cclist:    .word  0    # cclist: apunta a la lista de categorías
wclist:    .word  0    # wclist: apunta a la categoría seleccionada en curso				
schedv:    .space 32   # scheduler vector (guarda las direcc de las funciones primitivas)


espacio: .word 4

menu:
  .ascii "\nColecciones de objetos categorizados\n"
  .ascii "====================================\n"
  .ascii "1-Nueva categoria\n"
  .ascii "2-Siguiente categoria\n"
  .ascii "3-Categoria anterior\n"
  .ascii "4-Listar categorias\n"
  .ascii "5-Borrar categoria actual\n"
  .ascii "6-Anexar objeto a la categoria actual\n"
  .ascii "7-Listar objetos de la categoria\n"
  .ascii "8-Borrar objeto de la categoria\n"
  .ascii "0-Salir\n"
  .asciiz "Ingrese la opcion deseada: "


error:    .asciiz "Error: "
return:   .asciiz "\n"
catName:  .asciiz "\nIngrese el nombre de una categoria: "
selCat:   .asciiz "\nSe ha seleccionado la categoria:"
idObj:    .asciiz "\nIngrese el ID del objeto a eliminar: "
objName:  .asciiz "\nIngrese el nombre de un objeto: "
success:  .asciiz "La operación se realizo con exito\n\n"
actual:   .asciiz ">> "
notFound: .asciiz "not found"

.text
main:

la  $t0, schedv        # initialization scheduler vector (guarda las direcc de las primitivas)

la  $t1, newcategory
sw  $t1, 0($t0)

la  $t1, nextcategory
sw  $t1, 4($t0)

la  $t1, prevcategory
sw  $t1, 8($t0)

la  $t1, listcategories
sw  $t1, 12($t0)

la  $t1, delcategory
sw  $t1, 16($t0)

la  $t1, newobject
sw  $t1, 20($t0)

la  $t1, delobject
sw  $t1, 24($t0)

la  $t1, exit
sw  $t1, 32($t0)


inicio:

# imprime el menu de opciones
la $a0, menu           
li $v0, 4 
syscall

# input integer
li $v0 , 5
syscall

move $t2, $v0
 
beq $t2, 0 , exit              # exit
beq $t2, 1 , newcategory       # newcategory
beq $t2, 2 , nextcategory      # nextcategory   
beq $t2, 3 , prevcategory      # prevcategory
beq $t2, 4 , listcategories    # listcategories
beq $t2, 5 , delcategory       # delcategory
beq $t2, 6 , newobject         # newobject
beq $t2, 7 , listobjects       # listobjects
beq $t2, 8 , delobject         # delobject

blt $t2, $0 , else   # si la opcion ingresada es menor a 0 o mayor a 8 ,salta a la etiqueta "else"
bgt $t2, 8 , else

 


# ----------------------------------------------------------

# 1er word( ptr al ultimo nodo si es el primer nodo o ptr al nodo antecesor ),
# 2da word( ptr a su lista de objetos ),
# 3er word( ptr a bloque de strings ),
# 4to word( ptr a sucesor o ptr al primer nodo ) 
newcategory:

addiu $sp, $sp, -4
sw    $ra, 4($sp)

la    $a0, catName    # input category name
jal   getblock

move  $a2, $v0        # $a2 = *char to category name (el string ingresado por el usuario, retornado por la funcion "getBlock")
la    $a0, cclist     # $a0 = list , cclist apunta a la lista de categorías  
li    $a1, 0          # $a1 = NULL
jal   addnode         

lw    $t0, wclist     
bnez  $t0, newcategory_end
sw    $v0, wclist     # update working list if it was NULL


newcategory_end:

li    $v0, 0          # return success
lw    $ra, 4($sp)     		
addiu $sp, $sp, 4
j     inicio




# ----------------------------------------------------------

# Esto se hace con dos opciones en el menú: pasar a
# la categoría siguiente o a la anterior respecto a la actual.
nextcategory:

addiu $sp, $sp, -4
sw    $ra, 4($sp)

lw $a0 , wclist

beqz $a0 , error201  # la lista esta vacia ? 

lw $t0 , wclist    # se carga el nodo seleccionado actual CARGAR ACAA LA DIRECC DEL NODOOO, ESTUVE DOS HORAS! lw -> la                      
lw $t1 , 12($t0)   # siguiente nodo

beq $t0 , $t1 , error202  # hay un solo nodo ?

sw $t1 , wclist  # se guarda la categoria seleccionada actual

# se imprime la categoria seleccionada
la $a0 , selCat
li $v0 , 4
syscall

la $t2 , 8($t1)

lw $a0 , ($t2) # se imprime el nombre de la cat seleccionada
li $v0 , 4
syscall

j nextcategory_end


# error 201 : no hay categorias
error201: 

la $a0 , error
li $v0 , 4
syscall

li $a0 , 201
li $v0 , 1
syscall

j nextcategory_end

# error 202 : hay solo una categoria
error202: 

la $a0 , error
li $v0 , 4
syscall

li $a0 , 202
li $v0 , 1
syscall

j nextcategory_end


nextcategory_end:

lw    $ra, 4($sp)     		
addiu $sp, $sp, 4
j     inicio




# ----------------------------------------------------------

prevcategory:

addiu $sp, $sp, -4
sw    $ra, 4($sp)

lw $a0 , wclist

beqz $a0 , error201  # la lista esta vacia ? 

la $t0 , ($a0)    # se carga el nodo seleccionado actual CARGAR ACAA LA DIRECC DEL NODOOO, ESTUVE DOS HORAS! lw -> la                      
lw $t1 , 0($t0)   # $t1 -> nodo anterior al nodo actual

beq $t0 , $t1 , error202  # hay un solo nodo ?

sw $t1 , wclist  # se guarda la categoria seleccionada actual

# se imprime la categoria seleccionada
la $a0 , selCat
li $v0 , 4
syscall

la $t2 , 8($t1)

lw $a0 , ($t2) # se imprime el nombre de la cat seleccionada
li $v0 , 4
syscall

lw    $ra, 4($sp)     		
addiu $sp, $sp, 4
j     inicio




# ----------------------------------------------------------

listcategories: 

addiu $sp, $sp, -4
sw    $ra, 4($sp)

lw $t0 , cclist     # primer nodo

beqz $t0 , error301

lw $t2 , cclist    # copia del 1er nodo

lw $a1,  wclist 

li $t5 , 1   # bandera (para poder ejecutar el bucle)

while:
beq $t5 , 1 , body
beq $t0 , $t2 , endwhile    

body:
 
beq $a1 , $t0 , print_actual  # imprime cat actual

la $t4 , 8($t0)    # bloque de string

lw $a0 , ($t4)     # se imprime el nombre de la categoria
li $v0 , 4
syscall

lw $t0 , 12($t0)   # se carga en t0 el siguiente nodo de la lista,
addi $t5 ,$t5 , 1

j while

endwhile:
j listcategories_end


print_actual:

la $t4 , 8($t0)    # bloque de string

la $a0 , actual    # se imprime el simbolo " > "
li $v0 , 4
syscall

lw $a0 , ($t4)     # se imprime el nombre de la categoria actual
li $v0 , 4
syscall

lw $t0 , 12($t0)   # se carga en t0 el siguiente nodo de la lista,
beq $t0 , $t2 , endwhile
j while


error301:
la $a0 , error
li $v0 , 4
syscall

li $a0 , 301
li $v0 , 1
syscall

listcategories_end:
lw    $ra, 4($sp)     		
addiu $sp, $sp, 4
j     inicio




# ----------------------------------------------------------

delcategory:

addiu $sp, $sp, -4
sw    $ra, 4($sp)

la $a0 , wclist   # categoria actual (es la que se elimina de la lista)
la $a1 , cclist   # puntero a la lista

beq $a0 , $zero , error401 # 401: no hay categorias

lw $t0 , wclist   
lw $t2 , 4($t0)   # lista de objetos de la categoria

 
# borrar categoria sin objetos
delcat_non_object:

bne $t2 , $0 , delcat_objects  # se verifica si el nodo tiene objetos asignados

lw $t1 , 12($t0)  # siguiente categoria 

beq $t0,$t1,deluniquecat # verifica si es unica categoria en la lista 

jal delnode

lw $t1 , wclist    # actualiza categoria actual
lw $t1 , 12($t1)
sw $t1 , wclist # revisarr aca

j delcategory_end


deluniquecat: # unica categoria, nulificar punteros

jal delnode
sw $zero ,wclist

j delcategory_end



delcat_objects: # borrar objetos de una categoria,

# $t2 apunta a lista de objetos 

sw $zero , ($t2)  #se nulifica el 2do bloque del nodo  

# se debe verificar tambien si es una categoria unica o no
beq $t0,$t1,deluniquecat


error401:

la $a0 , error    # se imprime error 401
li $v0 , 4
syscall

li $a0 , 401     
li $v0 , 1
syscall


delcategory_end:
lw    $ra, 4($sp)     		
addiu $sp, $sp, 4
j     inicio




# ----------------------------------------------------------

newobject:

addiu $sp, $sp, -4
sw    $ra, 4($sp)

# si la lista esta vacia , lanzar error 501 (no hay categorias)
lw $t0 , cclist
beqz $t0 , error501

la    $a0, objName    # input category name
jal   getblock
move  $a2, $v0        # $a2, direcc del string ingresado por el usuario

lw $t0 , wclist
la $a0 , 4($t0)     # 2da word de la cat en curso apunta a obj

#lw $a0 , ($a0)
lw $t1 , 4($t0)
li $a1 , 1          # cargar id del objeto , de forma incremental 

# si 2da word de la cat es igual a 0 , entonces no hay objetos 
bnez $t1,add_non_unique_object

# first node
jal addnode
j newobject_end


add_non_unique_object:
# iterar hasta el ultimo objeto

lw $t1 , ($a0)  # 2da word es un objeto
lw $t2 , ($a0)  # copia del primer obj de la lista
li $t3 , 1      # bandera
lw $t4, 4($t1)  # id del objeto

while4:
beq $t3 , 1 , body3
beq $t1 , $t2 , endwhile4 

body3:

addi $t3 ,$t3 , 1
lw $t1 , 12($t1) # avanzo al sig objeto
addi $t4 ,$t4 , 1

j while4

endwhile4:
#addi $t4 ,$t4 , 1  # incremento el ID en 1
move $a1 , $t4 

jal addnode
j newobject_end

error501:
la $a0 , error
li $v0 , 4
syscall

li $a0 , 501
li $v0 , 1
syscall

newobject_end:
lw    $ra, 4($sp)     		
addiu $sp, $sp, 4
j     inicio




# ----------------------------------------------------------

listobjects: 

addiu $sp, $sp, -4
sw    $ra, 4($sp)

lw $t0 , wclist

beq $t0 ,$0, error601   # no hay categorias

lw $t1 , 4($t0)     # lista de objetos

beq $t1 ,$0, error602  # no hay objetos

lw $t1 , 4($t0) # id del objeto

# imprimir objetos de categoria en curso
li $t5 , 1   # bandera (para poder ejecutar el bucle)

lw $t2 , 4($t0) # $t2 -> copia del 1er objeto en la lista 

while2:
beq $t5 , 1 , body2
beq $t1 , $t2 , endwhile2    

body2:
 
la $t4 , 8($t1)    # bloque de string

lw $a0 , ($t4)     # se imprime el nombre del objeto
li $v0 , 4
syscall

lw $t1 , 12($t1)   # se carga en t1 el siguiente nodo de la lista,
addi $t5 ,$t5 , 1

j while2

endwhile2:
la $t4 , 8($t1)    # bloque de string

lw $a0 , ($t4)     # se imprime el nombre del objeto
li $v0 , 4
syscall
j listobjects_end


# error 601, no hay categorias creadas
error601:
la $a0 , error
li $v0 , 4
syscall

li $a0 , 601
li $v0 , 1
syscall

j listobjects_end

# error 602, no hay objetos para la categoria en curso
error602:
la $a0 , error
li $v0 , 4
syscall

li $a0 , 602
li $v0 , 1
syscall


listobjects_end:
lw    $ra, 4($sp)     		
addiu $sp, $sp, 4
j     inicio




# ----------------------------------------------------------

delobject:
addiu $sp, $sp, -4
sw    $ra, 4($sp)

# leer ID ingresado por usuario
# imprime id a eliminar
la $a0, idObj           
li $v0, 4 
syscall

# input integer
li $v0 , 5
syscall

move $t0, $v0  # ID ingresado por el usuario

# checkear si existe el ID (recorrer lista)
lw $t1 , cclist

# si no hay categorias ,lanzar error 701
beq $t1, $zero , error701

lw $t2 , wclist
lw $t3 , 4($t2)  # t3 -> lista de objetos

lw $t4 , 12($t3)

beq $t4 , $t3 , deluniqueobj


lw $t5 , 4($t3)  # first object's ID
li $t6 , 1

while5:
beq $t6 , 1 , body5
beq $t5 , $t4 , endwhile5

body5:
lw $t4 , 4($t3)  # ID del objeto

beq $t0 , $t4 , delete

lw $t3 , 12($t3)

addi $t6 , $t6 , 1

j while5


endwhile5:
j delobject_end


deluniqueobj:

move $a0 , $t3
la $a0 , ($a0)
lw $t1 , wclist
la $a1 , 4($t1)

jal delnode
lw $t1 , wclist
sw $zero , 4($t1)

j delobject_end


delete:

move $a0 , $t3
la $a0 , ($a0)
lw $t1 , wclist
la $a1 , 4($t1)

jal delnode

lw $t1 , wclist
lw $t3 , 12($t3)
sw $t3 , 4($t1)

j delobject_end


# error notFound
not_found:
la $a0 , notFound
li $v0 , 4
syscall

j delobject_end

# error 701 , no hay categorias
error701:
la $a0 , error
li $v0 , 4
syscall

li $a0 , 701
li $v0 , 1
syscall


delobject_end:
lw    $ra, 4($sp)     		
addiu $sp, $sp, 4
j     inicio




# -----------------------------------------------------


else:

la $a0, error           
li $v0, 4 
syscall
j main


exit:
li $v0, 10    # terminate program run and
syscall       # Exit 




# ----------------------------------------------------------

# node* addnode(list, node*)
# a0: list address
# a1: NULL if category, node address if object
# v0: node address added
addnode:

addi $sp, $sp, -8
sw   $ra, 8($sp)
sw   $a0, 4($sp)  # a0 ,caller saved convention
jal  smalloc


# set node content
sw   $a1, 4($v0)  # (ptr al 2do word del nodo (lista de objetos)) // object's ID
sw   $a2, 8($v0)  # se carga la direcc del string ingresado , en el 3er word del nodo
lw   $a0, 4($sp)  # a0 tiene la direcc de la lista de categorias/objetos
lw   $t0, ($a0)   # first node address
beqz $t0, addnode_empty_list

addnode_to_end:
lw   $t1, ($t0)   # last node address
 
# update prev and next pointers of new node
sw  $t1, 0($v0)   # puntero al nodo anterior
sw  $t0, 12($v0)  # puntero al nodo sig    

# update prev and first node to new node 
sw  $v0, 12($t1)  # 
sw  $v0, 0($t0)   # 
j   addnode_exit

addnode_empty_list:
sw  $v0, ($a0)    # se carga la direcc del nuevo bloque creado por smalloc, en $a0
sw  $v0, 0($v0)   # direcc del nodo anterior ,es el mismo nodo
sw  $v0, 12($v0)  # direcc del nodo siguiente ,es el mismo nodo

addnode_exit:
lw   $ra, 8($sp)
addi $sp, $sp, 8
jr   $ra




# ----------------------------------------------------------

# delnode(node*, list)
# a0: node address to delete
# a1: list address where node is deleted
delnode:

addi $sp, $sp, -8
sw $ra, 8($sp)
sw $a0, 4($sp)
lw $a0 , ($a0)
lw $a0, 8($a0)    # get block address (tercer campo del nodo,apunta a un bloque de strings)
 
jal sfree          # free block

lw $a0, 4($sp)    # restore argument a0
lw $a0 , ($a0)
lw $t0 , 12($a0)

beq $a0, $t0, delnode_point_self

lw $t1 ,0($a0)   # get address to prev node
sw $t1 ,0($t0)   # set prev node 
sw $t0 ,12($t1)  # set next node of prev node
lw $t1, ($a1)    # get address to first node again

bne $a0, $t1, delnode_exit  # verifica si el nodo selecc es el primero de la lista

sw $t0, ($a1)    # list point to next node

j delnode_exit

delnode_point_self:   # only one node
sw $zero, ($a1)    # cclist
sw $zero, ($a0)    # wclist


delnode_exit:
#lw $a0, 4($sp)    # restore argument a0
#sw $t0 , wclist  <<----------- ACA HAY UN PROBLEMAAA
jal  sfree
lw   $ra, 8($sp)
addi $sp, $sp, 8
jr   $ra




# ----------------------------------------------------------

# a0: msg to ask
# v0: block address allocated with string
getblock:

addi $sp, $sp, -4
sw   $ra, 4($sp)

li   $v0, 4      # se imprime string almacenado en $a0 ( "catName" )
syscall	

jal  smalloc

move $a0, $v0    # se guarda el nuevo bloque de memoria creado por smalloc,en $a0 

li   $a1, 16
li   $v0, 8      # se lee un string ingresado por el usario,y se almacena en $a0
syscall

move $v0, $a0     # $v0 ,contiene valor del string ingresado ,   
lw   $ra, 4($sp)  # la funcion retorna el string ingresado por el usuario , en $v0
addi $sp, $sp, 4
jr   $ra




# ----------------------------------------------------------

# memory management functions

smalloc:
lw   $t0, slist
beqz $t0, sbrk

move $v0, $t0

lw $t0, 12($t0)
sw $t0, slist
jr $ra

sbrk:
li $a0, 16 # node size fixed 4 words
li $v0, 9
syscall # return node address in v0
jr $ra

sfree: # crea una lista enlazada con nodos que se van eliminando
lw  $t0, slist
sw  $t0, 12($a0) 
sw  $a0, slist # $a0 node address in unused list
jr  $ra







