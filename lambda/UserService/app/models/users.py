from pydantic import BaseModel, Extra, confloat, conint, constr

class UserInputModel(BaseModel):
    email: constr(
            strip_whitespace=True
            )
    name: constr(
            strip_whitespace=True
            )
    username: constr(
        strip_whitespace=True, min_length=2
    )  
