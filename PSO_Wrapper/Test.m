addpath("/Users/danish/Cesadi/casadi-3-2")

import casadi.*
x = MX.sym('x')
disp(jacobian(sin(x),x))
