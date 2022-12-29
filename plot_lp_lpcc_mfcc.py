#!/usr/bin/env python
import matplotlib.pyplot as plt
    #Prueba ploteo
    # LP
X,Y = [],[]
for line in open('lp_2_3.txt', 'r'):
  values = [float(s) for s in line.split()]
  X.append(values[0])
  Y.append(values[1])
plt.figure(1)
plt.plot(X, Y, 'rx', markersize=4)
plt.savefig('lp_2_3.png')
plt.title('LP',fontsize=20)
plt.grid()
plt.xlabel('a(2)')
plt.ylabel('a(3)')
plt.savefig('lp_2_3.png')
plt.show()

    # LPCC
X, Y = [], []
for line in open('lpcc_2_3.txt', 'r'):
  values = [float(s) for s in line.split()]
  X.append(values[0])
  Y.append(values[1])
plt.figure(2)
plt.plot(X, Y, 'bx', markersize=4)
plt.savefig('lpcc_2_3.png')
plt.title('LPCC',fontsize=20)
plt.grid()
plt.xlabel('c(2)')
plt.ylabel('c(3)')
plt.savefig('lpcc_2_3.png')
plt.show()

    # MFCC
X, Y = [], []
for line in open('mfcc_2_3.txt', 'r'):
  values = [float(s) for s in line.split()]
  X.append(values[0])
  Y.append(values[1])
plt.figure(3)
plt.plot(X, Y, 'gx', markersize=4)
plt.savefig('mfcc_2_3.png')
plt.title('MFCC',fontsize=20)
plt.grid()
plt.xlabel('mc(2)')
plt.ylabel('mc(3)')
plt.savefig('mfcc_2_3.png')
plt.show()