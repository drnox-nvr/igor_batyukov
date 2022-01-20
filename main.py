# Igor Batyukov python practice homework

# 1. подсчет суммы в списке
print("1. подсчет суммы в списке")
my_list = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
print(f"list_sum =  {sum(my_list)}")
print('_________________________________')

# 2. Выявление дубликатов в списке, подсчет кол-ва различных значений, вычисление трех самых часто встречающихся элементов
print("2. Выявление дубликатов в списке, подсчет кол-ва различных значений, вычисление трех самых часто встречающихся элементов") 

my_list2 = ['a', 'b', 'c', 'b', 'd', 'm', 'n', 'n', 'z', 'z', 'z', 'a' ]
my_list3 = []

for i in my_list2:
  if my_list2.count(i) > 1:
    if i in my_list3:
      continue
    else:
        my_list3.append(i)

print(f"Дубли: {my_list3}")

dist_val = set(my_list2)
print(f"Количество различных значений: {len(dist_val)}")

d = {}

for k in my_list2:
  d[k] = my_list2.count(k)

sorted_d = sorted(d.items(), key=lambda x:x[1], reverse=True)

print("три самых часто встречающихся элемента:")
for f in list(range(3)):
  print(sorted_d[f]) 

print('_________________________________')
print("3. Елочка гори:")

picture = [
[0,0,0,1,0,0,0],
[0,0,1,1,1,0,0],
[0,1,1,1,1,1,0],
[1,1,1,1,1,1,1],
[0,0,0,1,0,0,0],
[0,0,0,1,0,0,0]
]


for x in picture:
  for item, value in enumerate(x):
    if x[item] == 1:
      x[item] = '*'
    else:
      x[item] = ' '
    
  print (''.join(map(str, x)))