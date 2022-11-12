let array = [1, 2, 3, 4, 1]
let oldVals

function checkDups(input){
    if(oldVals != input){
        console.log("no dups found, proceeding")
        return true
    }
    oldVals = input
}

if(checkDups(array)){
    console.log(array)
} else {
    console.log("some dups found")
}
