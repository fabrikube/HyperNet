ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1-unstable.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1-unstable.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data-unstable"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh
./fabric-dev-servers/createComposerProfile.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:unstable
docker tag hyperledger/composer-playground:unstable hyperledger/composer-playground:latest


# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d
# copy over pre-imported admin credentials
cd fabric-dev-servers/fabric-scripts/hlfv1/composer/creds
docker exec composer mkdir /home/composer/.composer-credentials
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer-credentials

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� Zx�Y �=�r�Hv��d3A�IJ��&��;cil� 	�����*Z"%�$K�W��$DM�B�Rq+��U���F�!���@^�� ��E�$zf�� ��ӧo�֍Ӈ*V���)����uث��1T��?yD"�����B�y"�Ĉ DCQ)�D#!1���Bp,� <�M�Ѭ�x˞�J��LK��x|�q2;������	s�|��j2��B;ç�ւuR�赑�#������K1�66m�%	�������+CFG3��B�=@J�K��y�0��fv��� ���(�
4U���&ˇ�[Ȇ*�!A�����)!H��X[��A�2e����
�0��Ӂ��b"�V��+�TrQ5R	�1�Eah��CL4�a �ŝ��a��l�<�)6��#�4-�`Û��^�USS_E�bjm�]~o�a �*���Q�I������z�P/��d��n�!�C�&���UԠn-lWk!��e	�<l��$,�t���萖c��u���e?������v�BX�����b�(��h냉-�ղ��$�sh��\�h��Xl�7��m����Ǆ����e"2����O��`����Ddٕ���2S��̑.b�!M�!�|[��O杻)�1����7��#�}�@v�MfWTT���Yti#Ӏ���Lڮs���V�󁫁}*����'|x�6��������$�����D)���'3���f�������k_�V�m���_1��I��(�r1*#k���@U3Uh58;�� �|(*��j&՘��u\.흗+�D��σ-|�=hwU�)p�cH��,_�.�5����O����z��X���3��&�#����i���Is��Ġ��������s���l9v"�~�vK��f��F&(�2�Й���#P�&٫u����P����ڎIwf^�mS�@�v�6ĊLD�k66{�Ӏ�	O]����A�E6��Ié�Ml`����n�i}�۔�б؜>sJx5��隂��-�i _�;���IdG��v��XÃ^Vu�4�����:���o��� �aEc�����o���h�ꃦ��:��;z�|�=�~������h�d!�7�.J�O!�?8O`�����>����}D�{�z2�Cj��AT��M���?Yד���}]�%�_�<���AA���_���3@�<Psv���AS�u ���;�"`:����K!�V�l����9�H�}��2m�>nqZ����H<��vσ�)I���40��I{�6$��l����� @6��z-�~2�\M#�'���^��4�f�`��F���YL'��{Kfh�."$�3械9;u���arޖwܭ�����X�]ib��]�;���l�DdfYu�#���{TE��S���&dl~=���I��'����`Ǌ���=r!B��h6�D��b�g7�D�8�Q)���ZXHG��Mi �<�#�9����ɘ|�d#ޛu�ޜ�1~����t�<�~"�פ�U��s�3<ʞn`���k �&��ׯG�S-ݩy}���C���#*�����_*̰��������"ᨰ������ϗ3�������`tZ�����j�����s�;s�����iW��c&�y�z�V]'�1MJ�h��`��%���OP'\y/[:/%�٣���D7!�����yvEog����r��s�}W��M��b6q~�*����������9�@��cX�~E�t�i�ܰ!�I#��d�]/��C����$�V����G��t�r����\,�����a�<��h��.�����b��֍!L�����_h��z'�b^>gQy��߁w�����<7���$̹����'�8�Ӫ"�?~|��R ҺtN�tzB'�i%LFد�<���i� (�$�_�����s��`'�E������
ѵ��X�_6���A�~��2��´�E��
xx��}����h��f��u��MT�.�����z�}�u�3��_���ߋ����:�s�|���^\p���o������'(x���M�(Y�������݅c���M��4��
�MͰ���4T����u��G6}���N�'�D�\L����0��k��������D�l������}��%=��O��e��AF���!ω^dd�~N�z�J�b��6UB/Ǻ/�Ign�L�H�;�NS�
�i����gf�����=��:�
�M�'�.����L����Xt��U&^+����S6p�;�S�t�O����@�4�.�on������G���P��k���p�J�#՚+��G�"bú�K!��B��z��h��8P����f |�_����x'l��T��ީ�(�:Qe���V���L��RdJ����Z�W� �o5� �eli����N�A����7�3?*8�`W����BK�#��/EC��ߕ�}��Q^�sw����,������=��:�4�	{��0�X��$���<��Ҟ� (ipn%�&I ���Ѐ7�9���*D��� u�?�r�FO�E/n�.�x���)J��K6`�5��gز�$#^2/i���c:E�D�&�,���%���ac*5����O'˘�c��X.�ɡN%�y~�w�K�f�Y�?e^���<3|Hx��6�df]]�h@��Bdx��J���b�f}A��y���h�Oh����b4(���Ww^��sՓ߾\�]���pt��'���+����ι�|����������k����?�PUP$)ۮ)�"J1X��$e;�Ԫ���B$�H�H�j,$)P��c1�������|���kn�������������8"��7�_Q���������M[sZ���O�����ʿ���6���$��ꛯFtx��=�ugm�����n��ɐ�O�oNL�y5��?l<%H;,�)"m0��p~��߮�{�]���3�Nm�]�����_|���Mަ�%�?xs���Z��U����O J��Jʆ;�ARz��kd��A7�O��Lm:Y��\�V��lY��{E%��F�5A�n����v����Ĥ`��l�PPB��@q;
cU1
aJR8J�ІԮy�Z�V��G!��d� �*���lB.�X�{#��&2���$�r7��٢�w���˞�gz�mTé�^�&��}|���R��\�����J*��%��s��+���	�r��oT3z�z����e�B��ϔr�<�����J;�A��4�}�)�o]\Neb����s��Ѩ��[g��E5(\�%e���ʩ`���8h����5�|��t��`�����	-�`e �qr��
V7Q8M
�T��q�*UΑ���K�s��`ڂ'g�n��S'�x��e.�ި�N6u�;=	_�����U���C�vO
'E��e2F��Q&m+�K����T��32��\&���)夘\Oe	�s7�'Y9�q��/�1Ӽ,�s���Ϳ�N�O.�v$I��X~�3�'�Q�X���}y?Ւ��sѳ�Y���Η�Y+�#gR���w�/���AN��Z�ު�n*���Փr���^1�k�)�B�s	��J�v�\b_��[�t��l<��0���~�c�E$ M!�������r''����
&d�.�R�D�����B佑H�?V˧HچW��I,�0�^F��0*'��q��P�l�ޏ�V�MO�i�j�T���E��{��qn�
Z/!Ţ5_)ʻ���|r���~��~:�F�@3���c��?��S���9�Q��'����3�obl/�[��W
�h�﫻}4����V��K�����?!Q���Vc~�Q1{L��O��ҧ\.��#6Y^d����U(�!�=8��c-Ӛ��S��P>J�[�Ϝ�zGO'�rU�/A�A\��,�N�*T��v�ҼJ�D��ձ�J��e՟r�q��+ýpZG���^0������S>� T�@����{e�P<����Snh�n�s��/~�_�i��k��
�l�ߩ~��/��g��u�ϕ�������q�nvS��=��#!�G!I��$u9�]3�NV`9�&wyRw������z����Y:�L!�)��u���Xc������m�-C>��ֽb{m�^�¤\��7��=�ܳ�ہO��^��4�����=x�_	["�����ai��q5�$p�g���l<G��m?�ui�������(ˣ�[߁������4d�Q�[�G}��F �u�>�D5��X��Ѩ.hhW�@�-h�:�~�E-����Cvi�?��e�8��5��} �~g� I܂����X�C�M)�6R�*����EPE:�$�jtd#0�`��zú2�1�=l��/y����<ﭹ�F�=
z�X�[�y��N�>6�>��A�li��`����d���{u]�xͦ?v5�B42����vL��k�������-Х��`��H(#2}�F�\it)xtذ�@h h��G���_��!��N0*�Ѷ-�v���]���UOޞMI �E�����b�L��6(��
Xа�|�t��ctdΰ����!SP�b}�ʭf{ã	m�3���cj*��gHph�D��/����+wu�I�;3���k�`����|s9����r�V��>���2���[�3t�C����JD��6_Ym�h������c�vz�k�2��.��<)���e|�	n0J����q��ְ)���t!�gY�`����R�sʯO�$���q�pwt/zR��T4Z�D�*a�f �:�h5�\�{A�xp(��R�c�$�&r��M��ZU<	��O��)v�������G{�,!�d��^�W�i�"���P�%�,��[9o�C�w��V�j�MG�]�TT6k���<&�=ԍ�ڡ���Ф�-�v����E����8�#P�vã�t7�5m��&�S���^����l��	�2$s��v�ڐ뼂u]�?�a=�'tp�m����J7���D�h�#�̧�'�t��}�1���G���r�?}o�Jm+��B�Y��Xc��L��)��G���-�Dz�o�B[~�#&�X�����%�q,-w�4������3�j���ʏ�Nr��ڎ�Ĺq�Γŕ;��qc'N�@�!�@K �7�݌`��,�° 6#�7���k�9~�y�wUn��i��{��>�����p���Sq���%!�C�/��Y��K���_Q�����_�ǿ���|�/��Ǒ�q�{8�@~����?z���+�6�u]L�򧟅�P4$+&�Cr��(�b���c
ERX��p+F�
�q� �R4F�!��h>��_��/�<���D?��}��s3�����3��|������W(Z=������.�m��|�=���=�χ�ׄR>�o_>��C�|[��ނ<�.� �X�Ŕ��+��f����-K)��+�K�2��y������1K��Bn�r�U�]���]�+v������l�\�7Evg����ͳK�z���+�B�!Y�����R�<���6�.�ZE����C�9s�֫�qc[4ZW(��ߥ8�!�;�a��d�-";�}3a��ܜ��ߚg�p����dyZ'b�P4�d�an���K���8�F������c~y�^09s�E3��5H���c�_�._fǚ�)�ȥ�b��D��D";+���LI˔���Jٶ��Lt����B
ehk�;Ɂ@G!b,m͏@ד� �&k�̢��l� z���rVs|��IJ�vѹN�0��H�K���&��(L�
|m��ԇ�vw|��(�E��"�w�I��=��K\G0�y,���c5S�&ǝq8��-��<�L;q>Y�Ze��f�R�(��a���������)?VD)��hE/����-vy��Wr�]���]���]���]���]q��]a��]Q��]A��]1��]!��]��.��%�����YJ�D�-���p%��X�v�=���j"^�1�%Ne�L+Ƈ�m�C܋�YQ�\������.��T�֪��v�'j���{�yk�n�~W�Ժ�e���b2�����9n�ِ�FU���-�Y�Ū)�/7eB'�Z�V�L��T8Q���ɱ|m���9��d��Z� ������4Ft�8N����\v���]�r�[�x+"�����O�N�±�L�D�R�A��fNgʬ�֫��� CF:���8O�2z�j�T�P�dR�F97i�k�R��n��(5�.�2���]��v��^|8
�e����k������+��nx]��{o�z%�b�!���[pq�ɷ6������O�}-p������u�נNM�x��޸�#�/o���u�b�?� �>
|���~�}�
���~���0����?x���JQ�YZ�L�V:�7�����L��.�\�X��vkK�K���	�.�:?Nl�}�L؂��L�<�\�m�f�R���Bnc5�%b����u�e��&0eW���[(0Q�"-2���,xf�8�1�R�R��,�D*2��T���D��Ĩ|�:;�c<�`|��:VX���v[4��>N�Ƽ��h����ʏӕ5��H�l)�:�e��J$�ZN���9�;��y�=��4�)T�CZ��NAe�����юJ����x�81���ܒ@�[O�F�*���K�YS��l�f�Vi��,��Z�����`P�1Q�E��Zβ :�D��_6[�e�t�fNcz�m�h�*ݰ�7f�L���h��:Y�n�2{��o]�4q`(7=C�PO�<_�i&�E39�3��[����Y`xW�g6�Ē��2;�v]��x\ńk�ȅ�����E��/���z���X�Y�q�ݑ������{t��e�%�ͪ6-$����r�-{����Dޘu$-����.N��[KJ6���j�<V��D�#L1��8h�pksu^���0��{}����R�<�8}�
Wh�6mC���@���,=&^0�ݩ�9��a��H�g�==�T��֞Nhu�)��N<��Tuɪ�X໴ MO[�h^I6*J:U�ey̥K�YaBm�H��K͋E�b�+���T�ݏ�T�����pa\)���i�1^ G�����F6�_^�Y(��J��٠0���T�cLF�J!a�*1��~��LҎ"�'\�QCn{#$M�L�����Y���*�ڎ�ʤ�yW� �=��
���
�J�4>>�)���<y�U\l�%�����t�JDg�B����X�F�J�,J2F�RZ�<�t�!m��T$��N�F��BA\��C�Dʙ�x:f
�å))xQ��Nz��
�qO!�-v�����7$��P��QKQ��d�9��\�����b�<= a� |T:�v��ZF%�,���T4M���Fa�58�k��hUc���˘ɳKC+��W߲l�G>����;~��+Dxv��˄V&�y6�/![����D����܌�~�Yp����..�J�A�-�M}���,���a$��-�K%�^��#�������?zy���󈶣����7�7��g�O��3�FE�T��!q/��&q�W
o�>F�$�����Ȫ�; �=�Lo�O����`%Cr
��'��N���Z��^vy�,-�E�=@!:�'��t���½Ƚ�����!�%������Aa���F���?�C����>����m��N��`�q=���$Ȫ���N�!�\/w:a4��������|���:L�UIzp,M��b@w�#7�8��� x#4����H?��=?}��Mڟ�ݯ�A��z �w�s��y�ڨ
}-CΏ.]/������{��̺^d�c�v�W��� 9�*ms��';����\@���[O��їE�%t����E?�9@H����aI:�Q ��FL�͢���,n ��	@���݅��Rߘf��76i�,��T�.��Y�K'� o��h����b�,0( �r�S!��S{��SÕ�e��
��U#���	g�Ɠ��;X⣠C?�����s���L��� 6�zkkݧ�]E�U�3u2�߽2k�}�9_m<D�� k���I+��Y�
+��
�OV���V(���c��:Csk�^#k��UfWu\�4�������Y��@�;d� ��,0�Lƅ�^t<ɭ� ��u�Rǒv,��N`�"�Z��J.'�/�^H���b����o"l�?�����;�4luGp�`C�~���
�߮�M�.~]����W5�$���C_��u�VO�����@t:�T��K�^o��΂;�� ��}�œЀ9���V�� >������
'?HJ����i..���Е����Ë0�t�-9����.��FX���AI�\ɚ(D�����mlK���w��8l��A�DW �J���2v1�3I���VI��K<����}�ݗlةӄ��b��m�W��$x����.<�:�v�@yB�c=�4%D8h�\�6P�R�	��z�g!'AB_�� ;�w�7����0@�r$����akE���3;���`:�ՀU�X��� ����P�Is�6���[���<O-��e�5��\�Ϸ�m�\���ȴ��~d�2Q%�����cOW"�i�j�i8
��wyh}��-�{/^x�����2�&���a)N[����j��wZ�Ht�P-��շV�Z��b�����'��Ό�>9��LF}��k���	6����0|�긲�}es"w��A>��Gƺmⶵ!�q"��sNbX�XI
��<�4r�8��nI`M��P*Љ 
��b��]W�a��h�w�ƺ�������ɧ8���;��ǻv�/k��c���������!n�l���d�،�I�"���o	�8d�O�O��ڲ��17lY	���\# �����Y'h���������U���:�&w,q�
W�ei���E>���x��3�h|�k]��	p8�t�\��)W�Y;A�R;DRMB��d$F(RBd��ڭ����H�$����r��l�()�*AIgz�d@��.�?V�0+��ǲJ��'��'���-����S0T3�ڣر ބ�u���ͪ�cR�"�f����XD�d�P�-L�I�DQ���TT	IM���B�LFcJ8��%)���4��?'���>�?��1�춁⛮����-	=��h�%p����vQ��q׾`g����]1/d�\��U'�,W�3g�\2�U��3YiN;g�K"��Y�ȕJ�0h]a����������_�u7{�'�\X�dPq:#��<��w<vUn�j�}�u�sP��֎�L�3�hl��8WC�I��Fwڄ���V�L�:����`�h�w�M��d�N�Z�۹a��t&`����Z�}@���/9L��䷢|^H��\�D��ɳ<�7���h>ϱ��6O�SN�g�g\������l:T�'(��{��L����б���~��%A�gE^zz���r��	��6����V�T�$�s��<�rb5W<��=s���iw��5ֱ$�3YO������a�YV���I�lI�E����"��%�Y�<e�K��s�x�e�19��FL%c��eP�o��G��'���;��ڒ�+�0��H �:vS{Dt�NSw��kh>x6��&�ݜ��ηl�1�-V�+X��������>�<j��9$��K�����rq�+$���"��e��Ō��f�<P(����f[ǻ��^�ɻY��0�E�_�����<�����2߉���#���ߒѷY��뿏�J��&�m������>���C�[�m��>���
��^ҫ �	۔�d$|���H�����ş�{��i_����8������������������Y�F镰�����^Ҿ�?E�I�.��`Q��ʸ%;�8&7�!���R+��-��b�v�"#�f$U����aBj��/�:���U���(|��;���K���a2o��l�ԡ�GZ��Α��>GSB���:ͅ�u]��+3Nr�*	T@ϩv�k�H�K�g�R���5�lq�?�F�j���"n��e}���O'�t�7�T�����WBXL��$u�Q��8���/���ӫ������^����!�=�Cڝ����9�ǩ���>ҫ �	l��� ����%�/������ �����������>�=��Ծ�)�J���?��{��xd���`��%��^�@��)���A������ږ��A��#�Z�����_ڗ���&�-�O�{�֥&�u����1Z3��MEE�/g "���Z��hw%��N�|��JU��5�ZsS���pT'�	Gu��G8H�?���'�T�_�C�_�������<� �W���Ck 
�?C<����[	ު��[�m>�*ݠ��y�qXw�N��K���?�Z�?CCJ����m������c��1޽�y[��޷�Y�דYL=�o�����,�`��¯VyC+��E��z�E���U�9�n��:Q̅�*�:_G���Z�a��
�E�j�'����=t��72������'�={�m���q�wȃztĝ��`^�))͞,m�^z��j��v���}ʗ���v�i꫱q���f�F�s�}#�h9��ʴ�{�X�ړu�2���a(���x������e��b���G����L$���k��eA,�z �����������R������'������O���O���O�	��
 ���$���� ����������_����H���o����B��������Z�_��L:�bz�,���:�n�����V�����u�����ƣ�!�}Y����:n�5�i@��`��CymĻ�`���H�i�ޣ���eB���FA�4I�B.���:cvN���>���no��ij�R�c��#����^}�	�Q,�ג~)�V���_��ؽ���m|�����u:!;%���;�ewŒ�HI��t�2��^2)�l�5���b"��3�ǋФ%i�_���	��V`�|�	��c�td�6���/��߀��#��?�_@@���K~H���5 ���[�����W�/��W��6.�3�,�Yb��L@��B���|R,�\HRA�S!2�@x�����Y�?����g���e�ӗ�DJ�V�d�<��Ӿ��Fԩ�,[�dm�S����3{{���S�.�#�Tݽ�ّ��66]���jrX�p�.6[J�=��y�&������� k�L�>�ó��:����@���������a]�Z���������Om@��_��2���7
��_}����ѴT稫��vs����3�uW��n���;����S{�WGr<h&�o^r�+df��Ses��;	e����*ƇqN��TqGv�.����p��`�<�-U�u���߷��?	�oM@�����_��7 ��/������_���_�������X�����(�_xK�y�U�����ALڲ�G�̈́�BM���!���%��g����v�cW����3 ��� ��z�� W��G�p)>U����7� ��<���.6�CJ�e�%W���ϱA�Ք�n��Zۥm+ö\�d#6���ODu�����^>�wUo�~)���f{a�Ş�Dߍ�OO����|�� �ے
C��{)V[�U|b��蓾�i�� 2ۧ��<Q��H*7X��9�Sv?7iW�9~�@���!5��VZ{�x~�I�&���x�@(�%k�H���1k5�ٱ[�Rc:�;R�L���b);��Ft�/�=1���Ќ��\d�ׇMjt��ag��">K&�_VNW��E�P��D�Ѡ������C&<�E�����8��p�T��ğ�`��T����,��������������������_o���5��G~�2~8���̟dD��/��ϲ�q8�����i>E�3^�h."|֏`��ÀB��l���O%���^?8�J-s��f�9$�$9��Y1za�Ftɚ�ZL�i��*�$���ŶKzi�[����]�?5�!��PR?K6�~��Iua�7�ˈ�E�^K�:g�ǎẤ��e��Zξ�S���~+P���������������%��P�����R��U 	�g������?�$��"��������U����P9���/�����*����w���
���~�����o��ߎ��e֔ڗt�%��Z[��aY���"���o�4؏�~��~d������q��(��xx�ǌ��S-y؛���#��%�h�ζc��މ3'�T/��,����J�mo5q�;��������$��y��
oڜ�����h�Ҏ}�8R��6v��*�Y�kۉ�o�6{�?r�&	�~�[�f�m�(��~��-�H�.ӡ}��8����ʚ%ӹn���ƻ��F4�3����������-F�I�5c-��M7f�2K[����Vw�����|<�ȴ��f�;�ˮ(迫ڃ�kB5��wGP�����'	
�_kB���������7KA�_%��o����o����?迏��u ������(�?���C����%� � ���I�/EC�_ ��!�����?���A�U��������y��������������$�?����������m�n �����p�w]���!�f �����ē���� ��p���_;�3O����J��C8Dը���7�����J ��� ������x�a��" ��`3�F@��{�?$��y�� ���?��� ��g�4�?T�����������I�A8D������H�?��kZ��U���I��� � �� ����������J���˓��������C��_��8�� ��0�_9P��a��>��?���������! ���'�� �W����}������(�?��{��(�?A\�`�G���)���B4����+I����C��C��9_������G��]���K@�_�T����Z�GW����ݹV��?U�R/��7`Y1�kE�'�i��U�b^_�61���x�>�[J�C�ڒ��P4eQ�Orn��03�U��e�Q�荼NAc�h�^�!saZ�qG����b�u����Ɉ�C����KO�8x��$c�����I���#����Yj������(�����H�?��������q-�~1~C���P�Շ�Y�B�`΍C�)Z���a�Foɝ�`V���"��E�ԭ���s���>�k�l���C��m����5�,p�<f�Gg���vMwz����].�ٹ-�;C�)2kFN��Q�m���ʘP�}+и�?���oE@�����_��7 ��/������_���_�������X����3�����-����k�R7Q�X޳[{b��/�V���V���߫��I;E�$�Md��ľ%��z�~�9a���V���4b�C��L	v�D��ph�'�݋�,>��c}�.Ų<�9���%��lF�����fn��{�v���+}��{�t�m��r[RaH���^�Ֆt�߉K���\蓾�i�� 2ۧ��<Q��H*7���9�Sv?7iW��B�P-Y�p���	����D0�T�ϴ��<��͹w����(4ڽ�����'3��
=?ՈY�Z3A$�8�L�Ft�Q��|�1���ﯻ+�����g���[�׿����8GB��|�����������p�� 
�A?�����J�џ��D7�BU\���'8��*���8�������@5����	��*�����k���I��*��g:�,�._�?󴱲�$�!H��§��\(?;�����=�C&�n��E��qS�?��+]c�=��h/���s?����
5���-_[��!�w�rx�.o��-��sl��)?9����u5$�����-e��P��Fή큊}=ި�^m�L�sq>&��g�ZL�e��-
��l2ҡG���u�ѢM�K�xJ0�\�S�/&��m��/Vދ��O������R<Uo_��8��~��7;ׇ�NӐ_�3%�I�8�7uvTC�v۲�#b�o+�i,#�*{l��F���e�͎�H��H䢗ؼD�t����`f���9�d"��i��k����n�Z,%nӗ
�<ŏ�&(�=��ԦB�/��c��+����~w �����?��V�j�0x��ps��I_�S!�_��P��4���|r4%�}�ؐ	�(?�Cb������������J�3��6���p�I�pL�f��(���1�v�h��������\��Z��#Wnj�����������0�_@A�������|���CU\�7�?�q���W	���z�����ځ?��<���b��p������;��a��4P�̋�w3ذ�y���~؏x7���obH�����}���}��gQ���XRI�:ܑ��nC�Qkia;��'}&l����`�i$|�%�"dEyDa����٣Ŝ���ɦՍ-�n��^��n�aO|??P�M"��8�y�!�w���N���E���t1��u��'&��L��,��fD�N4��դ-Qb�	�V�Y�E��ןj�u��2'�i-�u��N��X[v�f�k���h�b���~w����g�?��[	*��3>�a��<�Ss�$o���~�pQ4�'|����߄W]0�	��I��>B������������������_��n�6-��v�i��gz��q�自h�Y9�$�����-7Ղ�W���������-���G���U��U�=�?�_�����v�G$��_7�C�W}���_c ���������?GB�_	���ȷ������ִ��4wc�^O�{�<>.����O�pI��?��>��U�������\�C��"��(�J��b.Ջ��.�:�>��>�|~�-�޽s���uu�\a/GW.���sR�����ܜԩs���Cz��V*�����[9��� uj��mw҉Τ3�f3q}���D��w���Zkӧ�kV���>^���Jxa/�<���i9�Bg\�D{[[w:�T��hV�n�l=����}s|��*&��h�6�2�rڶ�t��H�1k	\�m����J	/Sh
�y���y�G�)q�<��n�x�=���gw;�b�ꇽ��v~��6lIi6F�í2�%Ym^���'�u����vcR��ld���j0��U���UL,ZJ�Ѷ�f�~���#ؕS�벵��R��p�qT��J%)�H]�+����|ß&�um�o��Ʉ,�C�?�����_��BG�����#��e�'_���L��O����O������ު���!�\��m�y���GG����rF.����o����&@�7���ߠ����-����_���-������gH���!��_�������_��C��@�A������_��T�����v ������E����(��B�����3W��@�� '�u!���_����� �����]ra��W�!�#P�����o��˅�/�?@�GF�A�!#���/�?$��2�?@��� �`�쿬�?����o��˅���?2r��P���/�?$���� ������h�������L@i�����������\�?s���eB>���Q�����������K.�?���D���V�1������߶���/R�?�������)�$�?g5���<7׭2m2��ͭb�5M�dR�����d˘d��ɱ÷�uz��E������lx��wz�(q��Fu����u��
M�)�ǭ�o2��wY��^�պ(����t�6ǝ6&w�Ɋ~HS,��8�m��/k��Ȏ�d�)-zB:]=h�V�E�Gu:,�q;,����m����d�U��\OS���՛�nǮU#�rEy�'����$YG���Wd�W�����E�n𜑇���U��a�7���y���AJ�?�}��n��%��:~��'jv��w�^���b�Q�ˆ��m��m��E��Ξ����Fu�j�[��j���#��͆�6,E�D8��~],���ߪb۰�sUk��ɫ�v��]mN���&�P;z��%�����7�{#��/D.� ����_���_0���������.��������_����n�QP�C��zVa��U���?��W��p���)VĚ8�)__�_ف����6��h�@*���z�.K�l�?���E��5}4o����D�0.L�x\��!iͱS��ˉI�U'�N��z�����~Q�j�J)l�[m,���m
��:;���_e�*��і����D�Z�F�1M!��bwXO����h�IJ�}v~s��V�~������^�|Jb���*P���r��KQ]٨5�V���v9X��ͦ2⇃8?LKQUZ�X�8���N�Y2D{�����qqېI�]?hB����|/Ƀ�G�P�	o��?� �9%���[�����Y������Y���?�xY������������Y������&��n�����SW�`�'����E�Q��-���\��+���	y���=Y����L�?��x{��#�����K.�?���/������ ���m���X���X�	������_
�?2���4�C����D�}{:bG[U�7��q������0�Z�)�#fs?��
����s?���L�G����"�w��Ϲ�������uy�ݢ��]�D�����8�P�;fm���\����j�7��O�gCvfNcap���M#��8:�!,Y��dSSmG��Q����Ѽ��_�Jޯ�WOG���\�F��4��
�}8V�����tu���_����Ug"��`1�lF90'<���%ik��Nt��jX#9jSo�}2�V,�X���`�fa�w��ReCi��DpT���vra���?2��/G�����m��B�a�y��Ǘ0
�)�������`�?������_P������"���G�7	���m��B�Y�9��+{� �[������-��RI��_�T�c�Q_D��q��Hmك�d�S����>�ǲ�<<�����،��i
���=��)������0��ыFI�h���z~��T�i��,u��7CS��W�*G}���hA�F�P/rq{+��eY!F�o� `i�����$�����B�{�X�/t)E�W��|aʜ�b�-?
�¢��nkO�����lX޴��P�G&��^S:K�X�!m�WЭ	�m�������?L.�?���/P�+���G��	���m��A��ԕ��E��,ȏ�3e�7�"oY�fh�f΋�N[,�s�N��E�d�l��a�OZk�:ϙ�O�9�c�V���L�������?r��?�������O�H&O��Q�Q�Nf��j�j�4*���<�ބ&{�`��Vb�埈`g��kL^�J���������ʝJ]X��5rr�4׉Y<�ZV p�|��n4��?_K���������q�������\�?�� ��?-������&Ƀ����������z�X�􎬊Ĝ�*Ċ��K���[Q�Ew��/�N��>�\_:���`K��_a;�YRL=4�,�G�~u�N�����[�iW||Ռڲn0.O������&^����24��%��E��3��g����``��"���_���_���?`���y��X��"�e��S�ϖ>�����ct�\���t/B�����S�����X �������wں�E[M�$������q��tc����r�J̧2�"��rV�#��'�`�)��Byh�X��a���שҬ�ڶ��RW�/�<,��DM���';O|�V�OE�;�q:&�BwX��u� v-a��$:9�6�RIv��������my�(�+�*"c���=QJ��S�M��MԵ�_�S��i�򳽈}U8P��Hԫ+��u��ˆď䓻p��J��ڞ[���b�n�0Fb��*4��Â�S�}�1�Յި���|8ezTqZ&�r�w��#O�9��}tx]���'����B�i&��?�ݹm�x������:��_v��Gm�(�����	bO�>J5�cG�?��+�y����<�Y���t�Ϧ��|L������]$�=c��������{=���G�����CI�������5�L�X���R��7?�%�����?}J����p�}���?�㾊��i>�����������.0�ox��D����n���Ǎpm�N������{,4#���'縉�i$����I_�zR��v��I�d���r��x�0qcfr��${{��(����7�x�#����w��~�c�=�I��%���w�����w܏�ɫ���[~I��OO;v������<Q�T ���;�r��}u��������<��XK����~��`m�m3�Ϗy��ӕ�渆�޳�M��"�`纎k��DނO��?q'w&�� �Bo�q�4����ÿ�Z�~����f�?�i,<��/���צ�������{��$�|��9��f@�{�M�t����?n�q��W��œ,���67aF���x�s�pM�ӓU=���SJZ��E�qwɍ'�{Տ�j�����H�VM�;���Hva*�����t�w�j�ez�w�ח������=q�}                           p���h� � 