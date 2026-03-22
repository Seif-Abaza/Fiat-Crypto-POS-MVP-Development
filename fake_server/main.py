"""
Fake Server (FSBP) - Backend for POS Device
Flask-based server to simulate backend operations
"""

import os
from datetime import datetime
from typing import Optional, Dict, Any, List
from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# In-memory storage for demonstration
device_pins: Dict[str, str] = {}
device_logs: Dict[str, List[Dict[str, Any]]] = {}
transactions: List[Dict[str, Any]] = []

# Default PIN for devices (in production, this would be in a database)
DEFAULT_PIN = "1234"


@app.route('/')
def root():
    return jsonify({"message": "FSBP - Fake Server Backend", "version": "1.0.0"})


@app.route('/auth/verify', methods=['POST'])
def verify_pin():
    """
    Verify device PIN
    """
    data = request.get_json()
    
    if not data or 'device_id' not in data or 'pin' not in data:
        return jsonify({
            "success": False,
            "message": "Missing device_id or pin"
        }), 400
    
    device_id = data.get('device_id')
    pin = data.get('pin')
    
    # In production, verify against database
    if pin == DEFAULT_PIN:
        # Generate a simple token
        token = f"token_{device_id}_{datetime.now().timestamp()}"
        return jsonify({
            "success": True,
            "message": "PIN verified successfully",
            "token": token
        })
    else:
        return jsonify({
            "success": False,
            "message": "Invalid PIN"
        })


@app.route('/logs', methods=['POST'])
def receive_logs():
    """
    Receive logs from POS device
    """
    data = request.get_json()
    
    if not data or 'device_id' not in data or 'level' not in data or 'message' not in data:
        return jsonify({
            "success": False,
            "message": "Missing required fields"
        }), 400
    
    device_id = data.get('device_id')
    level = data.get('level')
    message = data.get('message')
    timestamp = data.get('timestamp') or datetime.now().isoformat()
    
    if device_id not in device_logs:
        device_logs[device_id] = []
    
    device_logs[device_id].append({
        "level": level,
        "message": message,
        "timestamp": timestamp
    })
    
    print(f"[LOG] {level}: {message}")
    
    return jsonify({
        "success": True,
        "message": "Log received successfully"
    })


@app.route('/p2p/transaction', methods=['POST'])
def create_p2p_transaction():
    """
    Record P2P transaction and respond with OK
    """
    data = request.get_json()
    
    required_fields = ['device_id', 'amount', 'currency', 'crypto_currency', 
                       'wallet_address', 'exchange', 'price', 'commission', 'final_amount']
    
    if not data or not all(field in data for field in required_fields):
        return jsonify({
            "success": False,
            "message": "Missing required fields"
        }), 400
    
    transaction_id = f"txn_{len(transactions) + 1}_{datetime.now().timestamp()}"
    timestamp = datetime.now().isoformat()
    
    transaction = {
        "transaction_id": transaction_id,
        "device_id": data.get('device_id'),
        "amount": data.get('amount'),
        "currency": data.get('currency'),
        "crypto_currency": data.get('crypto_currency'),
        "wallet_address": data.get('wallet_address'),
        "exchange": data.get('exchange'),
        "price": data.get('price'),
        "commission": data.get('commission'),
        "final_amount": data.get('final_amount'),
        "timestamp": timestamp,
        "status": "completed"
    }
    
    transactions.append(transaction)
    
    print(f"[P2P TRANSACTION] ID: {transaction_id}, Amount: {data.get('amount')} {data.get('currency')}")
    
    return jsonify({
        "success": True,
        "message": "Transaction recorded successfully",
        "transaction_id": transaction_id,
        "timestamp": timestamp
    })


@app.route('/prices', methods=['GET'])
def get_prices():
    """
    Get simulated real-time exchange rates
    In production, this would proxy to OKX/Bybit APIs
    """
    # Simulated prices (in production, fetch from real APIs)
    prices = {
        "BTC": {
            "USDT": 67500.00,
            "USDC": 67480.00,
            "USD": 67450.00
        },
        "ETH": {
            "USDT": 3450.00,
            "USDC": 3448.00,
            "USD": 3445.00
        },
        "USDT": {
            "USD": 1.00,
            "EUR": 0.92,
            "GBP": 0.79
        },
        "USDC": {
            "USD": 1.00,
            "EUR": 0.92,
            "GBP": 0.79
        }
    }
    
    return jsonify({
        "success": True,
        "prices": prices
    })


@app.route('/webhooks/onramper', methods=['POST'])
def onramper_webhook():
    """
    Receive status notifications from Onramper provider
    """
    data = request.get_json() or {}
    timestamp = data.get('timestamp') or datetime.now().isoformat()
    
    print(f"[ONRAMPER WEBHOOK] Transaction: {data.get('transaction_id')}, Status: {data.get('status')}")
    
    return jsonify({
        "success": True,
        "message": "Webhook received successfully"
    })


@app.route('/webhooks/transak', methods=['POST'])
def transak_webhook():
    """
    Receive status notifications from Transak provider
    """
    data = request.get_json() or {}
    timestamp = data.get('timestamp') or datetime.now().isoformat()
    
    print(f"[TRANSAK WEBHOOK] Transaction: {data.get('transaction_id')}, Status: {data.get('status')}")
    
    return jsonify({
        "success": True,
        "message": "Webhook received successfully"
    })


@app.route('/webhooks/moonpay', methods=['POST'])
def moonpay_webhook():
    """
    Receive status notifications from MoonPay provider
    """
    data = request.get_json() or {}
    timestamp = data.get('timestamp') or datetime.now().isoformat()
    
    print(f"[MOONPAY WEBHOOK] Transaction: {data.get('transaction_id')}, Status: {data.get('status')}")
    
    return jsonify({
        "success": True,
        "message": "Webhook received successfully"
    })


@app.route('/webhooks/yellowcard', methods=['POST'])
def yellowcard_webhook():
    """
    Receive status notifications from Yellow Card provider
    """
    data = request.get_json() or {}
    timestamp = data.get('timestamp') or datetime.now().isoformat()
    
    print(f"[YELLOWCARD WEBHOOK] Transaction: {data.get('transaction_id')}, Status: {data.get('status')}")
    
    return jsonify({
        "success": True,
        "message": "Webhook received successfully"
    })


@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({"status": "healthy", "timestamp": datetime.now().isoformat()})


if __name__ == "__main__":
    port = int(os.getenv("PORT", "8000"))
    app.run(host="0.0.0.0", port=port, debug=True)
