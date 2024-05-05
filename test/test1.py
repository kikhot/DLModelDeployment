import gurobipy as gp
import numpy as np

def testFun():
    model = gp.Model('test')

    y = model.addVar(1, 4, vtype=gp.GRB.INTEGER, name='y')
    x1 = model.addVar(0, 1, vtype=gp.GRB.INTEGER, name='x1')
    x2 = model.addVar(1, 3.2, vtype=gp.GRB.INTEGER, name='x2')
    model.setObjective(y, gp.GRB.MAXIMIZE)
    
    model.addConstr(y == x1 * x2)
    
    # Optimize the model
    model.optimize()
    
    # Print the optimal solution
    model.display()
    model.printStats()
