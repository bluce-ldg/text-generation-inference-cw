install-server:
	cd server && make install

install-custom-kernels:
	if [ "$$BUILD_EXTENSIONS" = "True" ]; then cd server/custom_kernels && python setup.py install; else echo "Custom kernels are disabled, you need to set the BUILD_EXTENSIONS environment variable to 'True' in order to build them. (Please read the docs, kernels might not work on all hardware)"; fi

install-integration-tests:
	cd integration-tests && pip install -r requirements.txt
	cd clients/python && pip install .

install-router:
	cd router && cargo install --path .

install-launcher:
	cd launcher && cargo install --path .

install-benchmark:
	cd benchmark && cargo install --path .

install: install-server install-router install-launcher install-custom-kernels

server-dev:
	cd server && make run-dev

router-dev:
	cd router && cargo run -- --port 8080

rust-tests: install-router install-launcher
	cargo test

integration-tests: install-integration-tests
	pytest -s -vv -m "not private" integration-tests

update-integration-tests: install-integration-tests
	pytest -s -vv --snapshot-update integration-tests

python-server-tests:
	HF_HUB_ENABLE_HF_TRANSFER=1 pytest -s -vv -m "not private" server/tests

python-client-tests:
	pytest clients/python/tests

python-tests: python-server-tests python-client-tests

run-falcon-7b-instruct:
	text-generation-launcher --model-id tiiuae/falcon-7b-instruct --port 8080

run-falcon-7b-instruct-quantize:
	text-generation-launcher --model-id tiiuae/falcon-7b-instruct --quantize bitsandbytes --port 8080

clean:
	rm -rf target aml

run-llama2-13b-yanchao:
	# PYTHONIOENCODING=utf-8 CUDA_VISIBLE_DEVICES=0,1 text-generation-launcher --model-id /workspace/models/llama2-cw-20230807 --num-shard 2 --port 8000	
	PYTHONIOENCODING=utf-8 CUDA_VISIBLE_DEVICES=0,1 text-generation-launcher --model-id /workspace/models/llama2-cw-20230807 --port 8000 --dtype float16 --disable-custom-kernels --sharded false --max-concurrent-requests 2 --max-input-length 200 --max-total-tokens 400 --max-batch-prefill-tokens 400 
	# PYTHONIOENCODING=utf-8 CUDA_VISIBLE_DEVICES=0 text-generation-launcher --model-id /workspace/models/llama2-cw-20230807 --port 8000 --dtype float16 --disable-custom-kernels	--max-concurrent-requests 2 --max-input-length 200 --max-total-tokens 400  --max-batch-prefill-tokens 400 
	# PYTHONIOENCODING=utf-8 CUDA_VISIBLE_DEVICES=1 text-generation-launcher --model-id /workspace/models/llama2-cw-20230807 --port 8000 --max-concurrent-requests 2 --max-input-length 200 --max-total-tokens 800 

run-bloom-7b-yanchao:
	# PYTHONIOENCODING=utf-8 CUDA_VISIBLE_DEVICES=0,1 text-generation-launcher --disable-custom-kernels --model-id /workspace/models/bloomz-7b-newfmt-20230725 --num-shard 2  --port 8000	
	PYTHONIOENCODING=utf-8 CUDA_VISIBLE_DEVICES=0 text-generation-launcher --disable-custom-kernels --model-id /workspace/models/bloomz-7b-newfmt-20230725  --port 8000	

