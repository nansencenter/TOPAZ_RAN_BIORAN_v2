
hbar=1.6
bkcat=[0.0, 0.64, 1.39, 2.47, 4.56, 9.33]
a=[0.,0.,0.,0.,0.]
an=[0.,0.,0.,0.,0.]
H=[0.,0.,0.,0.,0.]
V=[0.,0.,0.,0.,0.]

a0=0.
##while ii <= 5:
for ii in range(5):
   if ii<4:
      hini=0.5*(bkcat[ii] + bkcat[ii+1])
   else:
      hini=bkcat[ii]+1.0
   a[ii]=max(0.,2.*hbar*hini-hini**2)
   H[ii]=hini
   a0=a0+a[ii]
   print(H[ii])
  
#

print('hbar=')
print(hbar)
print('Initialized aicen:')

for ii in range(5):
   an[ii]=a[ii]/a0
   b=H[ii]*an[ii]
   V[ii]=b
   print(an[ii])

print('Mean thickness of ice:')
print(sum(V)/sum(an))
