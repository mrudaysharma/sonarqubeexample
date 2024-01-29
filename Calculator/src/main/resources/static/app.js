function calculate(operation) {
    const num1 = document.getElementById('num1').value;
    const num2 = document.getElementById('num2').value;
    const resultElement = document.getElementById('result');

    fetch(`/calculator/api/${operation}?num1=${num1}&num2=${num2}`)
        .then(response => response.json())
        .then(data => {
            resultElement.textContent = data;
        })
        .catch(error => {
            console.error('Error:', error);
            resultElement.textContent = 'Error';
        });
}
