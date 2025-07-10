# %%
import numpy as np
import pandas as pd
import xgboost as xgb
from bayes_opt import BayesianOptimization
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split, RandomizedSearchCV
import warnings
warnings.filterwarnings('ignore')

def round_weights(weights):
    """Round weights according to specifications."""
    w1, w2, w3 = np.round(weights[:3], 2)
    wPL = np.round(weights[3], 7)
    return np.array([w1, w2, w3, wPL])

def prepare_data(data, selected_dcs=['US06City_extended', 'US06HW_extended']):
    """
    Prepare data for modeling using only the 4 weight features.
    Filters to only include selected drive cycles.
    """
    # Filter to include only the specified drive cycles
    filtered_data = data[data['DC'].isin(selected_dcs)]
    
    # Use only the 4 weight features (no drive cycle)
    X = filtered_data[['w1', 'w2', 'w3', 'wPL']]
    y = filtered_data['range']
    
    return X, y, filtered_data

def train_optimized_model(X, y):
    """
    Train an XGBoost model with hyperparameter tuning using a pipeline.
    """
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    
    pipeline = Pipeline([
        ('scaler', StandardScaler()),
        ('xgb', xgb.XGBRegressor(objective='reg:squarederror', random_state=42))
    ])
    
    param_space = {
        'xgb__max_depth': [3, 4, 5, 6, 7],
        'xgb__learning_rate': [0.01, 0.05, 0.1, 0.2],
        'xgb__n_estimators': [100, 200, 300],
        'xgb__min_child_weight': [1, 3, 5],
        'xgb__subsample': [0.7, 0.8, 0.9, 1.0],
        'xgb__colsample_bytree': [0.7, 0.8, 0.9, 1.0],
        'xgb__gamma': [0, 0.1, 0.2],
        'xgb__reg_alpha': [0, 0.1, 0.5],
        'xgb__reg_lambda': [1, 1.5, 2]
    }
    
    random_search = RandomizedSearchCV(
        pipeline,
        param_space,
        n_iter=30,
        cv=5,
        scoring='neg_mean_squared_error',
        random_state=42,
        verbose=1,
        n_jobs=-1
    )
    
    random_search.fit(X_train, y_train)
    best_pipeline = random_search.best_estimator_
    
    # Evaluate the model
    train_r2 = best_pipeline.score(X_train, y_train)
    test_r2 = best_pipeline.score(X_test, y_test)
    
    print(f"Train R² Score: {train_r2:.4f}")
    print(f"Test R² Score: {test_r2:.4f}")
    
    # Calculate RMSE on test set
    y_pred = best_pipeline.predict(X_test)
    rmse = np.sqrt(np.mean((y_pred - y_test) ** 2))
    print(f"Test RMSE: {rmse:.4f}")
    
    return best_pipeline

def find_optimal_weights(model, init_points=10, max_iter=100, tol=1e-3, patience=10):
    """
    Find a single optimal set of weights using Bayesian Optimization.
    Uses log-transformation for wPL and implements early stopping.
    """
    def bo_objective(w1, w2, w3, log_wPL):
        # Convert log_wPL back to the original scale
        wPL = 10**log_wPL
        weights = np.array([
            np.round(w1, 2),
            np.round(w2, 2),
            np.round(w3, 2),
            np.round(wPL, 7)
        ]).reshape(1, -1)
        
        return model.predict(weights)[0]  # Maximize the predicted range

    # Define parameter bounds: w1, w2, w3 in [0,1] and log10(wPL) in [-7,-4]
    pbounds = {
        'w1': (0, 1),
        'w2': (0, 1),
        'w3': (0, 1),
        'log_wPL': (-7, -4)
    }
    
    optimizer = BayesianOptimization(
        f=bo_objective,
        pbounds=pbounds,
        random_state=42,
        verbose=2
    )
    
    # Run initial exploration
    optimizer.maximize(init_points=init_points, n_iter=0)
    
    no_improve_count = 0
    current_iter = 0
    prev_best = optimizer.max['target']
    
    # Continue running one iteration at a time until stopping criteria is met
    while current_iter < max_iter and no_improve_count < patience:
        optimizer.maximize(init_points=0, n_iter=1)
        current_best = optimizer.max['target']
        
        if current_best - prev_best < tol:
            no_improve_count += 1
        else:
            no_improve_count = 0
            
        prev_best = current_best
        current_iter += 1
        
        # Print current progress
        if current_iter % 5 == 0:
            print(f"Iteration {current_iter}: Best range = {current_best:.4f}, No improvement count: {no_improve_count}")
    
    best_params = optimizer.max['params']
    best_wPL = 10**best_params['log_wPL']
    
    best_weights = np.array([
        np.round(best_params['w1'], 2),
        np.round(best_params['w2'], 2),
        np.round(best_params['w3'], 2),
        np.round(best_wPL, 7)
    ])
    
    best_range = optimizer.max['target']
    
    print(f"\nOptimization completed after {current_iter} iterations")
    print(f"Best weights found: w1={best_weights[0]}, w2={best_weights[1]}, w3={best_weights[2]}, wPL={best_weights[3]}")
    print(f"Predicted range with these weights: {best_range:.4f}")
    
    return best_weights, best_range

def predict_range_for_both_dcs(model, weights, data, dcs=['US06City_extended', 'US06HW_extended']):
    """
    Predict range for the given weights on each drive cycle separately and calculate statistics.
    """
    results = []
    
    for dc in dcs:
        # Filter data for this drive cycle
        dc_data = data[data['DC'] == dc]
        
        # Extract actual ranges for comparison
        actual_ranges = dc_data['range'].values
        
        # Create a dataset with the optimized weights
        X_pred = np.tile(weights, (len(dc_data), 1))
        
        # Predict ranges
        predicted_ranges = model.predict(X_pred)
        
        # Calculate error metrics
        mae = np.mean(np.abs(predicted_ranges - actual_ranges))
        rmse = np.sqrt(np.mean((predicted_ranges - actual_ranges) ** 2))
        mean_range = np.mean(predicted_ranges)
        
        results.append({
            'DC': dc,
            'Mean_Predicted_Range': mean_range,
            'MAE': mae,
            'RMSE': rmse
        })
    
    return pd.DataFrame(results)

def find_single_optimal_weights(data):
    """
    Main function: prepare data, train model, and find a single set of optimal weights
    that works well for both drive cycles.
    """
    # Prepare data (filtering to only FUDS and FUDSfast)
    X, y, filtered_data = prepare_data(data)
    
    print(f"Dataset shape after filtering: {X.shape}")
    print(f"Number of samples per drive cycle:")
    print(filtered_data['DC'].value_counts())
    
    # Train the model
    print("\nTraining model...")
    model = train_optimized_model(X, y)
    
    # Find optimal weights
    print("\nFinding optimal weights using Bayesian Optimization...")
    best_weights, best_range = find_optimal_weights(model)
    
    # Evaluate the optimized weights on each drive cycle
    print("\nEvaluating optimized weights on each drive cycle...")
    evaluation = predict_range_for_both_dcs(model, best_weights, filtered_data)
    
    return {
        'best_weights': best_weights,
        'best_range': best_range,
        'model': model,
        'evaluation': evaluation,
        'filtered_data': filtered_data
    }


# %%
# === Main Execution ===
if __name__ == '__main__':
    # Read your dataset (ensure the CSV path is correct)
    data = pd.read_csv('./Version_2_Combined_DataSet.csv')
    
    # Train the model and find a single set of optimal weights
    results = find_single_optimal_weights(data)
    
    # Display results
    best_weights = results['best_weights']
    print("\nOptimal weights for combined US DataSet")
    print(f"w1: {best_weights[0]}")
    print(f"w2: {best_weights[1]}")
    print(f"w3: {best_weights[2]}")
    print(f"wPL: {best_weights[3]}")
    print(f"Predicted optimal range: {results['best_range']:.4f}")
    
    print("\nPerformance on individual drive cycles:")
    print(results['evaluation'])
    
    # Save results to a CSV file
    results_df = pd.DataFrame({
        'w1': [best_weights[0]],
        'w2': [best_weights[1]],
        'w3': [best_weights[2]],
        'wPL': [f"{best_weights[3]:.10f}"],
        'predicted_range': [results['best_range']]
    })
    
    results_df.to_csv('XGBOOST_Combined_US_Optimal_Weights.csv', index=False)
    
    # Also save the evaluation results
    results['evaluation'].to_csv('XGBOOST_Combined_US_Evaluation.csv', index=False)


